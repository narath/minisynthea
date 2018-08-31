require_relative "../lib/id_store"

RSpec.describe IdStore, "#id" do
  it "creates a new id on each request" do
    ids = IdStore.instance
    id_1 = ids.id
    id_2 = ids.id
    expect(id_1).not_to eq(id_2)
  end

  it "does not create duplicate ids" do
    id_1 = IdStore.instance.id
    id_2 = IdStore.instance.id
    expect(id_1).not_to eq(id_2)
  end
end

