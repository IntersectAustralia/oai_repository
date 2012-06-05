Rails.application.routes.draw do

  mount OaiRepository::Engine => "/oai_repository"

  resources :persons
end
