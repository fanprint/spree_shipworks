module SpreeShipworks
  class GetStore
    include Dsl

    def call(params)
      response do |r|
        r.element "Store" do |r|
          r.element "Name", "#{params.fetch(:name, default_store.name)}"
          r.element "CompanyOrOwner", "Customer Support"
          r.element "Website", "#{params.fetch(:website, default_store.url)}"
        end
      end
    end

    private

    def default_store
      @default_store ||= Spree::Store.where(default: true).first
    end
  end
end
