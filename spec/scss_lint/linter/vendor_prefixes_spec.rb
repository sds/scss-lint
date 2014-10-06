require 'spec_helper'

describe SCSSLint::Linter::VendorPrefixes do
  context 'when a -webkit- prefix is used' do
    let(:css) { <<-CSS }
      div {
        -webkit-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a -moz- prefix is used' do
    let(:css) { <<-CSS }
      div {
        -moz-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a -o- prefix is used' do
    let(:css) { <<-CSS }
      div {
        -o-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a -ms- prefix is used' do
    let(:css) { <<-CSS }
      div {
        -ms-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a nonexistent -xyz- prefix is used' do
    let(:css) { <<-CSS }
      div {
        -xyz-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a nonexistent _xyz- prefix is used' do
    let(:css) { <<-CSS }
      div {
        _xyz-transition: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when ::-webkit-input-placeholder is used' do
    let(:css) { <<-CSS }
      ::-webkit-input-placeholder {
        color: red;
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when ::-moz-placeholder is used' do
    let(:css) { <<-CSS }
      ::-moz-placeholder {
        color: red;
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when ignore is set to placeholder' do
    let(:linter_config) { { 'ignore' => ['placeholder'] } }

    let(:css) { <<-CSS }
      :-ms-input-placeholder {
        color: red;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @-webkit-keyframes is used' do
    let(:css) { <<-CSS }
      @-webkit-keyframes anim {
        0%   { opacity: 0; }
        100% { opacity: 1; }
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when @-webkit-keyframes is used' do
    let(:css) { <<-CSS }
      @-webkit-keyframes anim {
        0% { opacity: 0; }
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when @-moz-keyframes is used' do
    let(:css) { <<-CSS }
      @-moz-keyframes anim {
        0% { opacity: 0; }
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when @-o-keyframes is used' do
    let(:css) { <<-CSS }
      @-o-keyframes anim {
        0% { opacity: 0; }
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when no vendor-prefix is used' do
    let(:css) { <<-CSS }
      div {
        transition: none;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @keyframes is used' do
    let(:css) { <<-CSS }
      @keyframes anim {
        0% { opacity: 0; }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when vendor-prefixed media queries are used' do
    let(:css) { <<-CSS }
    @media
      only screen and (-webkit-min-device-pixel-ratio: 1.3),
      only screen and (-o-min-device-pixel-ratio: 13/10),
      only screen and (min-resolution: 120dpi) {
        body {
          background: #fff;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a rule is empty' do
    let(:css) { <<-CSS }
      div {
      }
    CSS

    it { should_not report_lint }
  end

end
