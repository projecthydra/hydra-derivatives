require 'spec_helper'
require 'yaml'

describe Hydra::Derivatives::Processors::Jpeg2kImage do
  let(:object) { ActiveFedora::Base.new }
  let(:filename) { File.expand_path('../../fixtures/test.tif', __FILE__) }
  let(:image) { MiniMagick::Image.open(filename) }

  describe "#calculate_recipe" do
    it "calculates the number of levels from a size above the minimum threshold" do
      dim = 7200
      expect(described_class.level_count_for_size(dim)).to eq(6)
    end

    it "calculates the number of levels as 0 from a size below the minimum threshold" do
      dim = 50
      expect(described_class.level_count_for_size(dim)).to eq(0)
    end

    it "calculates the compression rates for each quality layer" do
      compression_num = 10
      layers = 8
      calc = described_class.layer_rates(layers, compression_num)
      expect(calc).to eq("2.4,1.48331273,0.91675694,0.56659885,0.3501847,0.21643059,0.13376427,0.0826726")
    end
  end

  describe ".srgb_profile_path" do
    it "exists" do
      expect(File.exist?(described_class.srgb_profile_path)).to eq true
    end
  end

  describe "#kdu_compress_recipe" do
    before(:all) do
      @sample_cfg = YAML.load_file(File.expand_path('../../fixtures/jpeg2k_config.yml', __FILE__))['test']
      Hydra::Derivatives.kdu_compress_recipes = @sample_cfg['jp2_recipes']
    end
    after(:all) do
      Hydra::Derivatives.reset_config!
    end

    it "can get the recipe from a config file" do
      args = { recipe: :myrecipe }
      r = described_class.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(@sample_cfg['jp2_recipes'][:myrecipe_grey])
    end

    it "can take a recipe as a string" do
      args = { recipe: '-my -excellent -recipe' }
      r = described_class.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(args[:recipe])
    end

    it "will fall back to a #calculate_recipe if a symbol is passed but no recipe is found" do
      args = { recipe: :x }
      r = described_class.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(described_class.calculate_recipe(args, 'grey', 7200))
    end

    it "will fall back to a #calculate_recipe if there is no attempt to provide one" do
      args = {}
      r = described_class.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(described_class.calculate_recipe(args, 'grey', 7200))
    end
  end

  describe "#encode" do
    it "executes the external utility" do
      expect(described_class).to receive(:execute) { 0 }
      described_class.encode('infile', 'recipe', 'outfile')
    end
  end

  describe "#tmp_file" do
    it "returns a temp file with the correct extension" do
      f = described_class.tmp_file('.test')
      expect(f).to end_with('.test')
    end
  end

  describe "long_dim" do
    it "returns the image's largest dimension" do
      expect(described_class.long_dim(image)).to eq(386)
    end
  end
end
