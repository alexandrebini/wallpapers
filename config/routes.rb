Wallpapers::Application.routes.draw do
  namespace :admin do
    root to: 'wallpapers#index'

    resources :wallpapers do
      collection do
        get :checking
      end
    end
  end
end