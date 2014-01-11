class TransactionsController < ApplicationController
  def new
    @transaction_form = TransactionForm.new
  end

  def create
    @transaction_form = TransactionForm.new(params[:transaction_form])


    if @transaction_form.submit
      redirect_to @transaction_form.transaction
    else
      render :new
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def index
    @transactions = Transaction.all
  end
end
