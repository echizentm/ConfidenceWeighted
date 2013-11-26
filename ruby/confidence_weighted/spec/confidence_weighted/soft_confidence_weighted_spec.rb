require 'spec_helper'

describe ConfidenceWeighted::SoftConfidenceWeighted do
  it 'should successfully initialize' do
    ConfidenceWeighted::SoftConfidenceWeighted.new(confidence: 1.0, aggressiveness: 1.0)
  end

  it 'should classify' do
    scw = ConfidenceWeighted::SoftConfidenceWeighted.new
    expect(scw.classify({})).to eq(-1)
  end

  it 'should not update with invalid label' do
    scw = ConfidenceWeighted::SoftConfidenceWeighted.new
    expect(scw.update({}, -2)).to eq(false)
    expect(scw.update({}, 0)).to eq(false)
    expect(scw.update({}, 2)).to eq(false)
  end

  it 'should successfully update' do
    scw = ConfidenceWeighted::SoftConfidenceWeighted.new
    expect(scw.update({}, -1)).to eq(true)
    expect(scw.update({}, 1)).to eq(true)
  end

end
