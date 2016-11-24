Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :imports, only: [:show] do
    get :diff, on: :member
  end
  resources :heap_dumps, only: [:show] do
    get 'generation(/:gen)', action: :generation, as: :generation, on: :member
  end
  root to: 'welcome#index'
end
