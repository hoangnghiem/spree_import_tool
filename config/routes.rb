Spree::Core::Engine.routes.draw do
  namespace :admin do
    namespace :utilities do
      scope 'import_products' do
        resources :sources, only: [:index, :create] do
          get :run, on: :member
          resource :mapping, only: [:show, :create]
        end
      end
      resources :import_product_images, only: [:index, :create]
    end
  end
end
