require 'spec_helper'

describe SCSSLint::Linter::SelectorFormat do
  context 'when class has alphanumeric chars and is separated by hyphens' do
    let(:css) { <<-CSS }
      .foo-bar-77 {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when id has alphanumeric chars and is separated by hyphens' do
    let(:css) { <<-CSS }
      #foo-bar-77 {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when element has alphanumeric chars and is separated by hyphens' do
    let(:css) { <<-CSS }
      foo-bar-77 {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when placeholder has alphanumeric chars and is separated by hyphens' do
    let(:css) { <<-CSS }
      %foo-bar-77 {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when pseudo-selector has alphanumeric chars and is separated by hyphens' do
    let(:css) { <<-CSS }
      [foo-bar-77=text] {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when selector has alphanumeric chars and is separated by underscores' do
    let(:css) { <<-CSS }
      .foo_bar {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when selector has is in camelCase' do
    let(:css) { <<-CSS }
      fooBar77 {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when placeholder has alphanumeric chars and is separated by underscores' do
    let(:css) { <<-CSS }
      %foo_bar {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'psuedo-selector has alphanumeric chars and is separated by underscores' do
    let(:css) { <<-CSS }
      :foo_bar {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when attribute has alphanumeric chars and is separated by underscores' do
    let(:css) { <<-CSS }
      [data_text] {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when attribute selector has alphanumeric chars and is separated by underscores' do
    let(:css) { <<-CSS }
      [data-text=some_text] {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when convention is set to snake_case' do
    let(:linter_config) { { 'convention' => 'snake_case' } }

    context 'when selector has alphanumeric chars and is separated by underscores' do
      let(:css) { <<-CSS }
        .foo_bar_77 {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when selector has alphanumeric chars and is separated by hyphens' do
      let(:css) { <<-CSS }
        .foo-bar-77 {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when selector has is in camelCase' do
      let(:css) { <<-CSS }
        .fooBar77 {
        }
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when convention is set to camel_case' do
    let(:linter_config) { { 'convention' => 'camel_case' } }

    context 'when selector has is in camelCase' do
      let(:css) { <<-CSS }
        .fooBar77 {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when selector capitalizes first word' do
      let(:css) { <<-CSS }
        .FooBar77 {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when selector has alphanumeric chars and is separated by underscores' do
      let(:css) { <<-CSS }
        .foo_bar_77 {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when selector has alphanumeric chars and is separated by hyphens' do
      let(:css) { <<-CSS }
        .foo-bar-77 {
        }
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when convention is set to use a regex' do
    let(:linter_config) { { 'convention' => /^[0-9]*$/ } }

    context 'when selector uses regex properly' do
      let(:css) { <<-CSS }
        .1337 {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when selector does not use regex properly' do
      let(:css) { <<-CSS }
        .leet {
        }
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when ignored names are set' do
    let(:linter_config) { { 'ignored_names' => ['fooBar'] } }

    context 'it ignores exact string matches' do
      let(:css) { <<-CSS }
        fooBar {
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when ignored types is set to class' do
    let(:linter_config) { { 'ignored_types' => ['class'] } }

    context 'it ignores all invalid classes' do
      let(:css) { <<-CSS }
        .fooBar {
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when ignored types is set to id, element, placeholder, pseudo-selector' do
    let(:linter_config) do
      { 'ignored_types' => %w[id attribute element placeholder pseudo-selector] }
    end

    context 'it ignores all invalid ids' do
      let(:css) { <<-CSS }
        #fooBar {
        }
      CSS

      it { should_not report_lint }
    end

    context 'it ignores all invalid elements' do
      let(:css) { <<-CSS }
        fooBar {
        }
      CSS

      it { should_not report_lint }
    end

    context 'it ignores all invalid placeholders' do
      let(:css) { <<-CSS }
        %fooBar {
        }
      CSS

      it { should_not report_lint }
    end

    context 'it ignores all invalid attributes' do
      let(:css) { <<-CSS }
        [fooBar=fooBar] {
        }
      CSS

      it { should_not report_lint }
    end

    context 'it ignores all invalid pseudo-selectors' do
      let(:css) { <<-CSS }
        :fooBar {
        }
      CSS

      it { should_not report_lint }
    end
  end
end
