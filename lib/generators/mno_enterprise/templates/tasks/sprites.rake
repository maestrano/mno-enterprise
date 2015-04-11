require 'sprite_factory'

namespace :assets do
  desc 'recreate sprite images and css'
  task :resprite => :environment do
    SpriteFactory.report  = true                         # output report during generation
    SpriteFactory.library = :chunkypng                   # use simple chunkypng gem to handle .png sprite generation
    SpriteFactory.layout  = :packed                      # pack sprite sheets into optimized rectangles
    SpriteFactory.style = :scss                          # Generates a css.scss file
    SpriteFactory.cssurl = "image-url('sprites/$IMAGE')"

    SpriteFactory.run!('vendor/sprites/icons', output_image: 'app/assets/images/sprites/icons.sprite.png', output_style: 'app/assets/stylesheets/sprites/icons.less', selector: '.i-ic-')
  end
end
