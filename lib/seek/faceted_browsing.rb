module Seek

  module FacetedBrowsing

    def items_for_result
      items = get_items
      resource_list_items = items.collect{|item| render_to_string :partial => "assets/resource_list_item", :object => item}

      respond_to do |format|
        format.json {
          render :json => {:status => 200, :items_for_result => resource_list_items.join(' ')}
        }
      end
    end

    def items_for_facets
      items = get_items
      items_for_facets = render_to_string :partial => "faceted_browsing/faceted_search",:object=>items

      respond_to do |format|
        format.json {
          render :json => {:status => 200, :items_for_facets => items_for_facets}
        }
      end
    end

    def get_items
      item_type = params[:item_type]
      item_ids = (params[:item_ids] || '').split(',')

      items = []
      if !item_type.blank?
        clazz = item_type.constantize
        items = clazz.find_all_by_id(item_ids)
        if clazz.respond_to?(:authorize_asset_collection)
          items = clazz.authorize_asset_collection(items,"view")
        else
          items = items.select &:can_view?
        end
      end

      items.sort!{|a,b| item_ids.index(a.id) <=> item_ids.index(b.id)}
      items
    end

    def ie_support_faceted_browsing?
      @ie_support_faceted_browsing = true
      user_agent = request.env["HTTP_USER_AGENT"]
      index = user_agent.try(:index, 'MSIE')
      if !index.nil?
        version = user_agent[(index+5)..(index+8)].to_i
        if version != 0 && version < 9
          @ie_support_faceted_browsing = false
        end
      end
      @ie_support_faceted_browsing
    end

  end
end
