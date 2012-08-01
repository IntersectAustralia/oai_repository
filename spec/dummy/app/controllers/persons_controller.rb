class PersonsController < ApplicationController
  def show
    @person = Person.find(params[:id])
  end

  def index
    @people = Person.all
  end
end
