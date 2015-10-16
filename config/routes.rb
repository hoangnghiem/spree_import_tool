Spree::Core::Engine.routes.draw do
  namespace :admin do
    namespace :utilities do
      scope 'import_products' do
        resources :sources, only: [:index, :create] do
          get :run, on: :member
          resource :mapping, only: [:show, :create]
        end
      end
    end
  end
end
