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

    context 'when selector is in camelCase' do
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

  context 'when ignored types is set to id, element, placeholder' do
    let(:linter_config) do
      { 'ignored_types' => %w[id attribute element placeholder] }
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
  end

  context 'when using a unique `id_convention`' do
    let(:linter_config) { { 'id_convention' => 'snake_case' } }

    context 'and actual id is correct' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        #snake_case {}
      CSS

      it { should_not report_lint }
    end

    context 'and actual id is incorrect' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        #hyphenated-lowercase {}
      CSS

      it { should report_lint line: 2 }
    end

    context 'and something else uses the `id_convention`' do
      let(:css) { <<-CSS }
        .snake_case {}
        #hyphenated-lowercase {}
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when using a unique `class_convention`' do
    let(:linter_config) { { 'class_convention' => 'camel_case' } }

    context 'and actual class is correct' do
      let(:css) { <<-CSS }
        .camelCase {}
        #hyphenated-lowercase {}
      CSS

      it { should_not report_lint }
    end

    context 'and actual class is incorrect' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        #hyphenated-lowercase {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and something else uses the `class_convention`' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        #camelCase {}
      CSS

      it { should report_lint line: 2 }
    end
  end

  context 'when using a unique `placeholder_convention`' do
    let(:linter_config) { { 'placeholder_convention' => 'snake_case' } }

    context 'and actual placeholder is correct' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        %snake_case {}
      CSS

      it { should_not report_lint }
    end

    context 'and actual placeholder is incorrect' do
      let(:css) { <<-CSS }
        .hyphenated-lowercase {}
        %hyphenated-lowercase {}
      CSS

      it { should report_lint line: 2 }
    end

    context 'and something else uses the `placeholder_convention`' do
      let(:css) { <<-CSS }
        .snake_case {}
        %snake_case {}
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when using a unique `element_convention`' do
    let(:linter_config) do
      {
        'convention' => 'camel_case',
        'element_convention' => 'hyphenated-lowercase'
      }
    end

    context 'and actual element is correct' do
      let(:css) { <<-CSS }
        hyphenated-lowercase {}
        #camelCase {}
      CSS

      it { should_not report_lint }
    end

    context 'and actual element is incorrect' do
      let(:css) { <<-CSS }
        camelCase {}
        #camelCase {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and something else uses the `element_convention`' do
      let(:css) { <<-CSS }
        hyphenated-lowercase {}
        #hyphenated-lowercase {}
      CSS

      it { should report_lint line: 2 }
    end
  end

  context 'when using a unique `attribute_convention`' do
    let(:linter_config) do
      {
        'convention' => 'camel_case',
        'attribute_convention' => 'hyphenated-lowercase'
      }
    end

    context 'and actual attribute is correct' do
      let(:css) { <<-CSS }
        [hyphenated-lowercase] {}
        #camelCase {}
      CSS

      it { should_not report_lint }
    end

    context 'and actual attribute is incorrect' do
      let(:css) { <<-CSS }
        [camelCase] {}
        #camelCase {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and something else uses the `attribute_convention`' do
      let(:css) { <<-CSS }
        [hyphenated-lowercase] {}
        #hyphenated-lowercase {}
      CSS

      it { should report_lint line: 2 }
    end
  end

  context 'when using a blend of unique conventions' do
    let(:linter_config) do
      {
        'convention' => 'camel_case',
        'element_convention' => 'hyphenated-lowercase',
        'attribute_convention' => 'snake_case',
        'class_convention' => /[a-z]+\-\-[a-z]+/
      }
    end

    context 'and everything is correct' do
      let(:css) { <<-CSS }
        #camelCase {}
        hyphenated-lowercase {}
        [snake_case] {}
        .foo--bar {}
      CSS

      it { should_not report_lint }
    end

    context 'some things are not correct' do
      let(:css) { <<-CSS }
        #camelCase {}
        camelCase {}
        [snake_case] {}
        .fooBar {}
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 4 }
    end

    context 'other things are not correct' do
      let(:css) { <<-CSS }
        #snake_case {}
        hyphenated-lowercase {}
        [camelCase] {}
        .foo--bar {}
      CSS

      it { should report_lint line: 1 }
      it { should report_lint line: 3 }
    end
  end

  context 'when the BEM convention is specified' do
    let(:linter_config) { { 'convention' => 'BEM' } }

    context 'when a name contains no underscores or hyphens' do
      let(:css) { '.block {}' }

      it { should_not report_lint }
    end

    context 'when a name contains single hyphen' do
      let(:css) { '.b-block {}' }

      it { should_not report_lint }
    end

    context 'when a name contains multiple hyphens' do
      let(:css) { '.b-block-name {}' }

      it { should_not report_lint }
    end

    context 'when a name contains multiple hyphens in a row' do
      let(:css) { '.b-block--modifier {}' }

      it { should report_lint }
    end

    context 'when a name contains a single underscore' do
      let(:css) { '.block_modifier {}' }

      it { should report_lint }
    end

    context 'when a block has name-value modifier' do
      let(:css) { '.block_modifier_value {}' }

      it { should_not report_lint }
    end

    context 'when a block has name-value modifier with lots of hyphens' do
      let(:css) { '.b-block-name_modifier-name-here_value-name-here {}' }

      it { should_not report_lint }
    end

    context 'when a name has double underscores' do
      let(:css) { '.b-block__element {}' }

      it { should_not report_lint }
    end

    context 'when element goes after block with modifier' do
      let(:css) { '.block_modifier_value__element {}' }

      it { should report_lint }
    end

    context 'when element has modifier' do
      let(:css) { '.block__element_modifier_value {}' }

      it { should_not report_lint }
    end

    context 'when element has not paired modifier' do
      let(:css) { '.block__element_modifier {}' }

      it { should report_lint }
    end

    context 'when element has hypenated modifier' do
      let(:css) { '.block__element--modifier {}' }

      it { should report_lint }
    end

    context 'when element has hypenated paired modifier' do
      let(:css) { '.block__element--modifier_value {}' }

      it { should report_lint }
    end
  end
end
