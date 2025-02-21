"""
------------------Prologue--------------------
File Name: stock_prediction_services.py
Path: kobrasuitecore/finances/services/stock_prediction_services.py

Description:
Contains functions for retrieving stock data, engineering technical indicators, and
running classification/regression models (including LSTM networks) to generate predictions.
Employs concurrency for horizon-based forecasting.

Input:
Stock ticker symbols and optional indicator flags for feature expansion.

Output:
Prediction metrics (accuracy, MSE, Sharpe ratio, etc.) and future price estimations.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
import logging
import numpy as np
import pandas as pd
import yfinance as yf
import keras
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.optimizers import Adam
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.preprocessing import MinMaxScaler
from sklearn.utils import class_weight
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score, accuracy_score, classification_report


def retrieve_data(ticker):
    now = datetime.now()
    start_date = (now - timedelta(days=5*365)).strftime('%Y-%m-%d')
    end_date = (now - timedelta(days=1)).strftime('%Y-%m-%d')
    df = yf.Ticker(ticker).history(start=start_date, end=end_date)
    if df.empty:
        return None
    df.drop(['Dividends', 'Stock Splits'], axis=1, inplace=True, errors='ignore')
    df['Tomorrow'] = (df['Close'].shift(-1) > df['Close']).astype(int)
    df['Week'] = (df['Close'].shift(-5) > df['Close']).astype(int)
    df['Month'] = (df['Close'].shift(-21) > df['Close']).astype(int)
    df['Close_Tomorrow'] = df['Close'].shift(-1)
    df['Close_NextWeek'] = df['Close'].shift(-5)
    df['Close_NextMonth'] = df['Close'].shift(-21)
    return df


def add_macd(df, fast=12, slow=26, signal=9):
    df['MACD_Line'] = df['Close'].ewm(span=fast, adjust=False).mean() - df['Close'].ewm(span=slow, adjust=False).mean()
    df['MACD_Signal'] = df['MACD_Line'].ewm(span=signal, adjust=False).mean()
    df['MACD_Hist'] = df['MACD_Line'] - df['MACD_Signal']
    return df


def add_rsi(df, window=14):
    delta = df['Close'].diff()
    gain = delta.where(delta > 0, 0).rolling(window=window).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=window).mean()
    rs = gain / loss
    df['RSI'] = 100 - (100 / (1 + rs))
    return df


def add_sma(df, window=14):
    df['SMA'] = df['Close'].rolling(window=window).mean()
    return df


def add_ema(df, window=14):
    df['EMA'] = df['Close'].ewm(span=window, adjust=False).mean()
    return df


def add_atr(df, window=14):
    hl = df['High'] - df['Low']
    hc = (df['High'] - df['Close'].shift()).abs()
    lc = (df['Low'] - df['Close'].shift()).abs()
    tr = pd.concat([hl, hc, lc], axis=1).max(axis=1)
    df['ATR'] = tr.rolling(window=window).mean()
    return df


def add_bbands(df, window=20):
    df['BB_Middle'] = df['Close'].rolling(window=window).mean()
    std = df['Close'].rolling(window=window).std()
    df['BB_Upper'] = df['BB_Middle'] + 2*std
    df['BB_Lower'] = df['BB_Middle'] - 2*std
    return df


def add_vwap(df):
    numerator = df['Volume'] * (df['High'] + df['Low'] + df['Close'])/3
    df['VWAP'] = numerator.cumsum() / df['Volume'].cumsum()
    return df


def add_indicators(df, MACD=False, RSI=False, SMA=False, EMA=False, ATR=False, BBands=False, VWAP=False):
    if MACD:
        df = add_macd(df)
    if RSI:
        df = add_rsi(df)
    if SMA:
        df = add_sma(df)
    if EMA:
        df = add_ema(df)
    if ATR:
        df = add_atr(df)
    if BBands:
        df = add_bbands(df)
    if VWAP:
        df = add_vwap(df)
    df.dropna(inplace=True)
    return df


def train_classification(df, horizon):
    if df.shape[0] < 50:
        return None
    target_map = {1: 'Tomorrow', 2: 'Week', 3: 'Month'}
    target_col = target_map.get(horizon)
    if target_col not in df.columns:
        return None
    df = df.dropna(subset=[target_col])
    X = df.select_dtypes(include=[np.number]).drop(columns=[
        'Tomorrow','Week','Month','Close_Tomorrow','Close_NextWeek','Close_NextMonth'
    ], errors='ignore')
    y = df[target_col].astype(int)
    train_size = int(len(X)*0.8)
    X_train, X_test = X.iloc[:train_size], X.iloc[train_size:]
    y_train, y_test = y.iloc[:train_size], y.iloc[train_size:]
    classes = np.unique(y_train)
    cw = class_weight.compute_class_weight('balanced', classes=classes, y=y_train)
    cw_dict = dict(zip(classes, cw))
    model = LinearDiscriminantAnalysis()
    model.fit(X_train, y_train)
    preds = model.predict(X_test)
    acc = accuracy_score(y_test, preds)
    rep = classification_report(y_test, preds)
    next_data = X.iloc[[-1]]
    next_pred = model.predict(next_data)[0]
    return {'accuracy': acc, 'classification_report': rep, 'today_prediction': int(next_pred)}

def train_regression(df, horizon):
    if df.shape[0] < 50:
        return None
    target_map = {1: 'Close_Tomorrow', 2: 'Close_NextWeek', 3: 'Close_NextMonth'}
    target_col = target_map.get(horizon)
    if not target_col:
        return None
    df = df.dropna(subset=[target_col])
    features = df.select_dtypes(include=[np.number]).drop(columns=[
        'Tomorrow','Week','Month','Close_Tomorrow','Close_NextWeek','Close_NextMonth'
    ], errors='ignore').values
    targets = df[target_col].values
    seq_len = {1: 5, 2: 7, 3: 10}.get(horizon, 5)
    scaler_x = MinMaxScaler()
    scaler_y = MinMaxScaler()
    fx = scaler_x.fit_transform(features)
    fy = scaler_y.fit_transform(targets.reshape(-1,1))
    X_seq = []
    Y_seq = []
    for i in range(len(fy)-seq_len):
        X_seq.append(fx[i:i+seq_len])
        Y_seq.append(fy[i+seq_len-1])
    X_seq = np.array(X_seq)
    Y_seq = np.array(Y_seq)
    if X_seq.shape[0] < 10:
        return None
    idx = int(len(X_seq)*0.8)
    X_train, X_test = X_seq[:idx], X_seq[idx:]
    Y_train, Y_test = Y_seq[:idx], Y_seq[idx:]
    model = keras.Sequential()
    model.add(LSTM(64, activation='relu', input_shape=(X_train.shape[1], X_train.shape[2])))
    model.add(Dropout(0.2))
    model.add(Dense(1))
    model.compile(optimizer=Adam(learning_rate=0.001), loss='mean_squared_error')
    model.fit(X_train, Y_train, epochs=25, batch_size=32, verbose=0)
    preds = model.predict(X_test)
    preds_rescaled = scaler_y.inverse_transform(preds)
    y_test_rescaled = scaler_y.inverse_transform(Y_test)
    mse = mean_squared_error(y_test_rescaled, preds_rescaled)
    mae = mean_absolute_error(y_test_rescaled, preds_rescaled)
    r2 = r2_score(y_test_rescaled, preds_rescaled)
    last_block = fx[-seq_len:]
    last_block = np.expand_dims(last_block, axis=0)
    p = model.predict(last_block)
    final_pred = scaler_y.inverse_transform(p)[0][0]
    return {'mse': mse, 'mae': mae, 'r2': r2, 'prediction': round(final_pred, 2)}


def get_predictions(ticker, MACD=False, RSI=False, SMA=False, EMA=False, ATR=False, BBands=False, VWAP=False):
    df = retrieve_data(ticker)
    if df is None:
        return None
    df = add_indicators(df, MACD=MACD, RSI=RSI, SMA=SMA, EMA=EMA, ATR=ATR, BBands=BBands, VWAP=VWAP)
    results = {}
    def train_for_horizon(h):
        c = train_classification(df.copy(), h)
        r = train_regression(df.copy(), h)
        return (h, c, r)
    with ThreadPoolExecutor(max_workers=3) as ex:
        futures = [ex.submit(train_for_horizon, h) for h in [1,2,3]]
        for f in as_completed(futures):
            horizon, cresult, rresult = f.result()
            if cresult and rresult:
                lab = {1:'Tomorrow',2:'Week',3:'Month'}[horizon]
                results[lab] = {'classification': cresult, 'regression': rresult}
    return results if results else None