# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class ContributionsController < BaseController
      include User::VerificationHelper

      before_action(only: [:new, :create]) { check_visibility_level(find_contribution_container, current_user) }

      def new
        @contribution_container = find_contribution_container
        @contribution_form = ContributionForm.new(site_id: current_site.id)
      end

      def create
        @contribution_container = find_contribution_container
        @contribution_form = ContributionForm.new(contribution_params.merge(site_id: current_site.id,
                                                                            contribution_container_id: @contribution_container.id,
                                                                            user_id: current_user.id))

        if @contribution_form.save
          track_create_activity

          redirect_to(
            gobierto_participation_process_contribution_container_path(@contribution_container.slug, process_id: current_process.slug)
          )
        else
          render(:new, layout: false) && return if request.xhr?
          render :new
        end
      end

      def show
        @contribution = find_contribution
        @contribution_container = @contribution.contribution_container
        @process = @contribution.contribution_container.process
        @comment_form = CommentForm.new(site_id: current_site.id)

        respond_to do |format|
          format.js
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoParticipationContributionActivity.broadcast_event("contribution_created", default_activity_params.merge(subject: @contribution_form.contribution))
      end

      def default_activity_params
        { ip: remote_ip, author: current_user, site_id: current_site.id }
      end

      def contribution_params
        params.require(:contribution).permit(
          :title,
          :description
        )
      end

      def ignored_contribution_attributes
        %w(slug created_at updated_at)
      end

      def find_contribution
        current_site.contributions.find_by!(slug: params[:id])
      end

      def find_contribution_container
        current_site.contribution_containers.find_by!(slug: params[:contribution_container_id])
      end
    end
  end
end
