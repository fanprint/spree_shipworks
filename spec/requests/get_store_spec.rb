require 'spec_helper'

describe 'GetStore action' do
  # based on information in the XML schema definition, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <Store>
  #     <Name>My Example Store</Name>
  #     <Website>http://spree.example.com</Website>
  #   </Store>
  # </ShipWorks>

  let(:action) { 'getstore' }

  context 'without action_params' do
    let(:action_params) { {} }

    include_context 'for ShipWorks actions'
    it_should_behave_like "a ShipWorks API action"

    it 'should use the store name from the default spree store' do
      expect(xml.xpath('/ShipWorks/Store/Name').text).to eq('Spree Demo Site')
    end

    it 'should use the store site url from the default spree store' do
      expect(xml.xpath('/ShipWorks/Store/Website').text).to eq('demo.spreecommerce.com')
    end
  end

  context 'with store params' do
    let(:store) { Spree::Store.new(name: 'Expected Store Name', url: 'expected.spree_url.com') }
    let(:action_params) { { name: store.name, website: store.url } }

    include_context 'for ShipWorks actions'
    it_should_behave_like "a ShipWorks API action"

    it 'should use the store name from the spree store' do
      expect(xml.xpath('/ShipWorks/Store/Name').text).to eq(store.name)
    end

    it 'should use the store site url from the spree store' do
      expect(xml.xpath('/ShipWorks/Store/Website').text).to eq(store.url)
    end
  end
end
