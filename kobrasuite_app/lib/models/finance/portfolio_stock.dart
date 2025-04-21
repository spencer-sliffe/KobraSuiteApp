class PortfolioStock{
  final String ticker;
  final String name;
  final int numberOfShares;
  final double ppsAtPurchase;
  final double closePrice;
  final double currentValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPct;
  final double percentageChange;
  PortfolioStock({required this.ticker,required this.name,required this.numberOfShares,required this.ppsAtPurchase,required this.closePrice,required this.currentValue,required this.totalInvested,required this.profitLoss,required this.profitLossPct,required this.percentageChange});
  factory PortfolioStock.fromJson(Map<String,dynamic> j)=>PortfolioStock(
      ticker:j['ticker']??'',
      name:j['name']??'',
      numberOfShares:j['number_of_shares']??0,
      ppsAtPurchase:(j['pps_at_purchase'] as num).toDouble(),
      closePrice:(j['close_price'] as num).toDouble(),
      currentValue:(j['current_value'] as num).toDouble(),
      totalInvested:(j['total_invested'] as num).toDouble(),
      profitLoss:(j['profit_loss'] as num).toDouble(),
      profitLossPct:(j['profit_loss_percentage'] as num).toDouble(),
      percentageChange:(j['percentage_change'] as num).toDouble());
  Map<String,dynamic> toJson()=>{
    'ticker':ticker,
    'name':name,
    'number_of_shares':numberOfShares,
    'pps_at_purchase':ppsAtPurchase,
    'close_price':closePrice,
    'current_value':currentValue,
    'total_invested':totalInvested,
    'profit_loss':profitLoss,
    'profit_loss_percentage':profitLossPct,
    'percentage_change':percentageChange};
}