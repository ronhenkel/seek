class DocumentsController < ApplicationController

  include Seek::IndexPager

  include Seek::AssetsCommon

  before_filter :find_assets, :only => [ :index ]
  before_filter :find_and_authorize_requested_item, :except => [ :index, :new, :create, :request_resource,:preview, :test_asset_url, :update_annotations_ajax]
  before_filter :find_display_asset, :only=>[:show, :download]

  include Seek::Publishing::PublishingCommon

  include Seek::BreadCrumbs
  include Seek::Doi::Minting

  include Seek::IsaGraphExtensions

  def new_version
    if handle_upload_data
      comments = params[:revision_comment]

      respond_to do |format|
        if @document.save_as_new_version(comments)
          create_content_blobs

          flash[:notice] = "New version uploaded - now on version #{@document.version}"
        else
          flash[:error] = "Unable to save new version"
        end

        format.html { redirect_to @document }
      end
    else
      flash[:error] = flash.now[:error]
      redirect_to @document
    end
  end

  # PUT /documents/1
  def update
    update_annotations(params[:tag_list], @document)
    update_scales @document

    @document.attributes = document_params

    update_sharing_policies @document

    respond_to do |format|
      if @document.save
        update_relationships(@document,params)
        update_assay_assets(@document,params[:assay_ids])
        flash[:notice] = "#{t('document')} metadata was successfully updated."
        format.html { redirect_to document_path(@document) }

      else
        format.html {
          render :action => "edit"
        }
      end
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :description, { project_ids: [] }, :license, :other_creators,
                                { special_auth_codes_attributes: [:code, :expiration_date, :id, :_destroy] })
  end

  alias_method :asset_params, :document_params
end
