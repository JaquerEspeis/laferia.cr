# frozen_string_literal: true

# Controller used to provide the API products for the DFC application
module DfcProvider
  module Api
    class CatalogItemsController < BaseController
      def index
        render json: @user, serializer: DfcProvider::PersonSerializer
      end

      def show
        render json: variant, serializer: DfcProvider::CatalogItemSerializer
      end

      private

      def variant
        @variant ||=
          Spree::Variant.
            joins(product: :supplier).
            where('enterprises.id' => @enterprise.id).
            find(params[:id])
      end
    end
  end
end
