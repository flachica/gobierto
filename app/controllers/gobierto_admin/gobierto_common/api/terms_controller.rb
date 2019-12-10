# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module Api
      class TermsController < ::GobiertoAdmin::Api::BaseController
        include ::GobiertoCommon::SecuredWithToken

        skip_before_action :authenticate_admin!, :set_admin_with_token
        before_action :set_admin_by_session_or_token

        def create
          load_vocabulary

          term = @vocabulary.terms.find_or_create_by(term_params)

          render json: term, serializer: ::GobiertoAdmin::GobiertoCommon::TermSerializer
        end

        private

        def load_vocabulary
          @vocabulary = current_site.vocabularies.find(params[:vocabulary_id])
        end

        def term_params
          params.require(:term).permit(name_translations: {})
        end

        def set_admin_by_session_or_token
          set_admin_with_token unless (@current_admin = find_current_admin).present?
        end

      end
    end
  end
end
