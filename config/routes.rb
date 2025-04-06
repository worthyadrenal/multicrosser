Rails.application.routes.draw do
  get 'puzzles/index'
  get 'puzzles/show'
  get 'puzzles/new'
  get 'puzzles/create'
  root 'page#index'

  get 'crossword/:source/:series/:identifier/:room', to: 'rooms#show', as: 'room'
  get 'crossword/:source/:series/:identifier', to: 'crosswords#show', as: 'crossword'
  get 'crosswords/fetch/:source/:id', to: 'crosswords#fetch', as: 'fetch_crossword'



end
