class Jpi::V1::ShoppingCartController < ApplicationController
  # before_filter :authenticate_user!, except: [:apps]
  # before_filter :inject_cart_and_authorize, only: [:show,:upsert_item,:remove_item,:checkout]
  #
  # # When a user signs in from the shopping
  # # cart, the CSRF token seems to change therefore
  # # preventing any POST request later on
  # # TODO: We should be able to grab the new CSRF token on
  # # login and inject it in angular
  # skip_before_filter :verify_authenticity_token
  #
  # # GET /mnoe/jpi/v1/shopping_cart/apps
  # # params:
  # # - ensure_apps: [{ app: {id: 16 } }] (as string) -- ensure that some apps are present in the list
  # def apps
  #   @apps = App.active.to_a
  #
  #   if params[:ensure_apps].present?
  #     begin
  #       id_list = JSON.parse(params[:ensure_apps]).map { |h| (h['app']||{})['id'] }.compact
  #       @apps += App.where(id: id_list).to_a
  #       @apps.uniq!
  #     rescue
  #     end
  #   end
  #
  #   @apps.sort! { |a,b| a.name <=> b.name }
  #
  #   render json: @apps.map { |a| Shopping::Cart.hash_for_app(a) }
  # end
  #
  # # GET /mnoe/jpi/v1/shopping_cart/organizations
  # def organizations
  #   @orgs = Organization.accessible_by(Ability.new(current_user)).sort_by { |o| o.name }
  # end
  #
  # # GET /mnoe/jpi/v1/shopping_cart/1
  # def show
  # end
  #
  # # POST /mnoe/jpi/v1/shopping_cart
  # # TODO: add test for bundle parameter on create
  # def create
  #   organization = Organization.find(params[:shopping_cart][:organization_id])
  #   bundle = params[:shopping_cart][:bundle]
  #   authorize! :purchase, organization
  #
  #   @cart = Shopping::Cart.create(requestor: current_user, beneficiary: organization, bundle: bundle)
  #
  #   render 'show'
  # end
  #
  # # PUT /mnoe/jpi/v1/shopping_cart/1/upsert_item
  # def upsert_item
  #   @item = @cart.add_item!(params[:item])
  #   render 'show_item'
  # end
  #
  # # PUT /mnoe/jpi/v1/shopping_cart/1/remove_item
  # def remove_item
  #   @item = @cart.remove_item!(params[:item])
  #   render 'show_item'
  # end
  #
  # # PUT /mnoe/jpi/v1/shopping_cart/1/checkout
  # def checkout
  #   if @cart.checkout!(params[:credit_card])
  #     render 'show'
  #   else
  #     render json: @cart.errors, status: :bad_request
  #   end
  #
  # end
  #
  # #============================================
  # # Private Methods
  # #============================================
  # private
  #   # Inject @cart and authorize access
  #   # TODO: use CanCan for authorization
  #   def inject_cart_and_authorize
  #     @cart = Shopping::Cart.find(params[:id])
  #
  #     unless @cart.requestor == current_user
  #       render json: { errors: 'unauthorized' }, status: :unauthorized
  #       return false
  #     end
  #
  #     return true
  #   end
end