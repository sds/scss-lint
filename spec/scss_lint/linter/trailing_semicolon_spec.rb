# encoding: utf-8

require 'spec_helper'

describe SCSSLint::Linter::TrailingSemicolon do
  context 'when a property does not end with a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property ends with a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a property ends with a space followed by a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0 ;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property ends with a semicolon and is followed by a comment' do
    let(:css) { <<-CSS }
      p {
        margin: 0;  // This is a comment
        padding: 0; /* This is another comment */
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a property contains nested properties' do
    context 'and there is a value on the namespace' do
      let(:css) { <<-CSS }
        p {
          font: 2px/3px {
            style: italic;
            weight: bold;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'and there is no value on the namespace' do
      let(:css) { <<-CSS }
        p {
          font: {
            style: italic;
            weight: bold;
          }
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when a nested property does not end with a semicolon' do
    let(:css) { <<-CSS }
      p {
        font: {
          weight: bold
        }
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when a multi-line property ends with a semicolon' do
    let(:css) { <<-CSS }
      p {
        background:
          top repeat-x url('top-image.jpg'),
          right repeat-y url('right-image.jpg'),
          bottom repeat-x url('bottom-image.jpg'),
          left repeat-y url('left-image.jpg');
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a multi-line property does not end with a semicolon' do
    let(:css) { <<-CSS }
      p {
        background:
          top repeat-x url('top-image.jpg'),
          right repeat-y url('right-image.jpg'),
          bottom repeat-x url('bottom-image.jpg'),
          left repeat-y url('left-image.jpg')
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a oneline rule does not end with a semicolon' do
    let(:css) { <<-CSS }
      .foo { border: 0 }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a oneline rule has a space before a semicolon' do
    let(:css) { <<-CSS }
      .foo { border: 0 ; }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when @extend does not end with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        @extend %bar
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when @extend ends with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        @extend %bar;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @include does not end with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        @include bar
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when @include takes a block' do
    let(:css) { <<-CSS }
      .foo {
        @include bar {
          border: 0;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @include takes a block with nested props' do
    let(:css) { <<-CSS }
      .foo {
        @include bar {
          .bar {
            border: 0;
          }
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @include takes a block with an if-node' do
    let(:css) { <<-CSS }
      .foo {
        @include bar {
          @if $var {
            border: 0;
          }
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @include ends with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        @include bar;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @import ends with a semicolon' do
    let(:css) { '@import "something";' }

    it { should_not report_lint }
  end

  context 'when @import does not end with a semicolon' do
    let(:css) { '@import "something"' }

    it { should report_lint line: 1 }
  end

  context 'when @import has a space before a semicolon' do
    let(:css) { '@import "something" ;' }

    it { should report_lint line: 1 }
  end

  context 'when an import directive is split over multiple lines' do
    context 'and is missing the trailing semicolon' do
      let(:css) { <<-CSS }
        @import 'functions/strip-units',
                'functions/pc'
      CSS

      it { should report_lint }
    end

    context 'and is not missing the trailing semicolon' do
      let(:css) { <<-CSS }
        @import 'functions/strip-units',
                'functions/pc';
      CSS

      it { should_not report_lint }
    end
  end

  context 'when variable declaration does not end with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        $bar: 1
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when variable declaration ends with a semicolon' do
    let(:css) { <<-CSS }
      .foo {
        $bar: 1;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when variable declaration ends with multiple semicolons' do
    let(:css) { <<-CSS }
      .foo {
        $bar: 1;;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when interpolation within single quotes is followed by property' do
    context 'and property has a trailing semicolon' do
      let(:css) { "[class~='\#{$test}'] { width: 100%; }" }

      it { should_not report_lint }
    end

    context 'and property does not have a trailing semicolon' do
      let(:css) { "[class~='\#{$test}'] { width : 100% }" }

      it { should report_lint }
    end
  end

  context 'when triggering a bug based on Windows IBM437 encoding' do
    CSS = <<-CSS
      @charset "UTF-8";

      .foo:before {
        content: '▼';
      }
    CSS
    let(:css) { CSS.force_encoding('IBM437') }

    it { should_not report_lint }
  end
end
