class PersonsController < ApplicationController
  def show
    @person = Person.find(params[:id])
  end

  def index
  end
end
