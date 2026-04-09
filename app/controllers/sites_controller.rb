class SitesController < ApplicationController
   allow_unauthenticated_access only: %i[ home ]

   def home
   end
end