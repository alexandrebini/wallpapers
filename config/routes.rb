Wallpapers::Application.routes.draw do
  get '/(pg-:page)' => 'wallpapers#index', as: :root

  namespace :admin do
    root to: 'wallpapers#index'

    resources :wallpapers do
      collection do
        get :checking
      end
    end
  end
end