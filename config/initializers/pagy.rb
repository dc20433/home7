require 'pagy'

# require "pagy/extras/bootstrap"

# Safe-guard against third-party gems (like pagy-cursor) that freeze Pagy defaults
if Pagy::DEFAULT.frozen?
  unfrozen_default = Pagy::DEFAULT.dup
  Pagy.send(:remove_const, :DEFAULT)
  Pagy::DEFAULT = unfrozen_default
end

Pagy::DEFAULT[:items] = 15       # Sets default per-page count to 15