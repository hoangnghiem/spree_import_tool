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
      resource :test_background_job, only: [:show, :create]
      resource :exportings, only: [:show] do
        post :export_images
      end
    end
  end
end
