require "spec_helper"

shared_examples "a has_many relation" do

  let(:target) do
    target_class.new
  end

  let(:target_1) do
    target_class.new(name: 1)
  end

  let(:target_2) do
    target_class.new(name: 2)
  end

  let(:targets) do
    [target_1, target_2]
  end

  let(:new_base) do
    base_class.new
  end

  let(:persisted_base) do
    base_class.create
  end

  let(:new_relation) do
    new_base.send(relation_name)
  end

  let(:persisted_relation) do
    persisted_base.send(relation_name)
  end

  let(:metadata) do
    base_class.am_relations[relation_name.to_s]
  end

  describe ".<<" do

    context "when base is not persisted" do


      before do
        new_relation << target
      end

      after do
        new_relation.clear
      end

      context "when target is empty" do

        it "initializes with enumerable target" do
          expect(new_relation.size).to eq(1)
        end

        it "does not persist" do
          new_relation.each do |target|
            expect(target).to_not be_persisted
          end
        end

      end

      context "when target is not empty" do

        let(:new_target) do
          target_class.new
        end

        before do
          new_relation << new_target
        end


        it "append with enumerable target" do
          expect(new_relation.size).to eq(2)
        end

        it "does not persist" do
          new_relation.each do |target|
            expect(target).to_not be_persisted
          end
        end

      end

    end

    context "when base is persisted" do

      before do
        persisted_relation << target
      end

      after do
        persisted_relation.clear
      end

      context "when target is empty" do

        it "initializes with enumerable target" do
          expect(persisted_relation.size).to eq(1)
        end

        it "does persist" do
          persisted_relation.each do |target|
            expect(target).to be_persisted
          end
        end

        it "binds foreign_key" do
          persisted_relation.each do |target|
            expect(target.send(metadata.foreign_key)).to eq(persisted_base.id)
          end
        end

      end

      context "when target is not empty" do

        let(:new_target) do
          target_class.new
        end

        before do
          persisted_relation << new_target
        end


        it "append with enumerable target" do
          expect(persisted_relation.size).to eq(2)
        end

        it "does persist" do
          persisted_relation.each do |target|
            expect(target).to be_persisted
          end
        end

        it "binds foreign_key" do
          persisted_relation.each do |target|
            expect(target.send(metadata.foreign_key)).to eq(persisted_base.id)
          end
        end


      end

    end

  end

  describe ".build" do

    context "when base is not persisted" do

      before do
        new_relation.build
      end

      after do
        new_relation.clear
      end

      context "when target is empty" do

        it "initializes with enumerable target" do
          expect(new_relation.size).to eq(1)
        end

        it "does not persist" do
          new_relation.each do |taret|
            expect(target).to_not be_persisted
          end
        end

      end

      context "when target is not empty" do

        before do
          new_relation.build
        end

        it "append with enumerable target" do
          expect(new_relation.size).to eq(2)
        end

        it "does not persist" do
          new_relation.each do |target|
            expect(target).to_not be_persisted
          end
        end

      end

    end

    context "when base is persisted" do

      before do
        persisted_relation.build
      end

      after do
        persisted_relation.clear
      end

      context "when target is empty" do

        it "initializes with enumerable target" do
          expect(persisted_relation.size).to eq(1)
        end

        it "does not persist" do
          persisted_relation.each do |target|
            expect(target).to_not be_persisted
          end
        end

        it "binds foreign_key" do
          persisted_relation.each do |target|
            expect(target.send(metadata.foreign_key)).to eq(persisted_base.id)
          end
        end

      end

      context "when target is not empty" do

        before do
          persisted_relation.build
        end

        it "append with enumerable target" do
          expect(persisted_relation.size).to eq(2)
        end

        it "does not persist" do
          persisted_relation.each do |target|
            expect(target).to_not be_persisted
          end
        end

        it "binds foreign_key" do
          persisted_relation.each do |target|
            expect(target.send(metadata.foreign_key)).to eq(persisted_base.id)
          end
        end

      end

    end

  end

  [ :create, :create! ].each do |method|

    describe ".#{method}" do

      context "when base is persisted" do

        before do
          persisted_relation.send(method)
        end

        after do
          persisted_relation.clear
        end

        context "when target is empty" do

          it "initializes with enumerable target" do
            expect(persisted_relation.size).to eq(1)
          end

          it "does not persist" do
            persisted_relation.each do |target|
              expect(target).to be_persisted
            end
          end

        end

        context "when target is not empty" do

          context "when sending single" do

            before do
              persisted_relation.send(method)
            end

            it "append with enumerable target" do
              expect(persisted_relation.size).to eq(2)
            end

            it "does not persist" do
              persisted_relation.each do |target|
                expect(target).to be_persisted
              end
            end

          end

          context "when sending multiple" do

            before do
              persisted_relation.send(method, [{name: 1}, {name: 2}])
            end

            it "append with enumerable target" do
              expect(persisted_relation.size).to eq(3)
            end

            it "does not persist" do
              persisted_relation.each do |target|
                expect(target).to be_persisted
              end
            end
          end

        end

      end

    end

  end

  context ".delete" do

    before do
      persisted_relation << targets
    end

    after do
      persisted_relation.clear
    end

    it "deletes the specified team" do
      persisted_relation.delete(target_1)
      expect(persisted_relation.map(&:id)).to eq([target_2.id])
      expect(target_1.send(metadata.foreign_key)).to be_nil
    end

    it "deletes all teams" do
      expect(target_class).to receive(:delete_all).once.with({metadata.foreign_key.to_s => persisted_base.id})
      persisted_relation.delete_all
    end

    it "destroys all teams" do
      expect(target_class).to receive(:destroy_all).once.with({metadata.foreign_key.to_s => persisted_base.id})
      persisted_relation.destroy_all
    end

  end

  context ".find" do

    before do
      persisted_relation << targets
    end

    it "finds the specified target" do
      target = persisted_relation.find(target_1.id)
      expect(target).to eq(target_1)
    end

    context "when find_or" do

      context "when initialize_by" do

        let(:new_name) do
          "foo"
        end

        it "returns item when found" do
          target = persisted_relation.find_or_initialize_by({name: 1})
          expect(target).to eq(target_1)
          expect(target).to be_persisted
        end

        it "initializes item when not found" do
          target = persisted_relation.find_or_initialize_by({name: new_name})
          expect(target.name).to eq(new_name)
          expect(target).to_not be_persisted
        end

      end

      context "when create_by" do

        let(:new_name) do
          "foo"
        end

        it "returns item when found" do
          target = persisted_relation.find_or_create_by({name: 1})
          expect(target).to eq(target_1)
          expect(target).to be_persisted
        end

        it "initializes item when not found" do
          target = persisted_relation.find_or_create_by({name: new_name})
          expect(target.name).to eq(new_name)
          expect(target).to be_persisted
        end

      end

    end

  end


end
