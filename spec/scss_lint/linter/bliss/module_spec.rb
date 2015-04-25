require 'spec_helper'

describe SCSSLint::Linter::Bliss::Module do
  let(:linter_config) { {
    'module_name' => 'Foo',
    'ignored_utility_class_prefixes' => ['is']
  } }

  context 'when a module class is used from a different module' do
    let(:scss) { <<-SCSS }
      .Foo {
        .Bar {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a utility class is used' do
    let(:scss) { <<-SCSS }
      .Foo {
        .bar {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a utility class is added to ignored_utility_class_prefixes' do
    let(:scss) { <<-SCSS }
      .Foo {
        .isOk &-bar {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when an ignored_utility_class_prefixes utility class is used as the last descendant selector' do
    let(:scss) { <<-SCSS }
      .Foo {
        &-bar .isNotOk {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_utility_classes_in_module is enabled and a utility class is used (not as last descendant selector)' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_utility_direct_styling' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        .utilOk &-bar {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when any utility class is used as the last descendant selector' do
    let(:scss) { <<-SCSS }
      .Foo {
        &-bar .any-util {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_utility_direct_styling is enabled and any utility class is used as the last descendant selector' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_utility_direct_styling' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        &-bar .any-util {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when allow_element_selector_in_module is false and element selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_element_selector_in_module' => false
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        span {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_element_selector_in_module is true and element selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_element_selector_in_module' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        span {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when allow_attribute_selector_in_module is false and attribute selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_attribute_selector_in_module' => false
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        [foo="bar"] {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_attribute_selector_in_module is true and attribute selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_attribute_selector_in_module' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        [foo="bar"] {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when allow_id_selector_in_module is false and id selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_id_selector_in_module' => false
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        #bar {
          color: blue;
        }
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_id_selector_in_module is true and id selector is used' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_id_selector_in_module' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        #bar {
          color: blue;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when allow_module_margin is false and margin is applied to module' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_module_margin' => false
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        margin-top: 10px;
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_module_margin is true and margin is applied to module' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_module_margin' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        margin-top: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when allow_module_width is false and width is applied to module' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_module_width' => false
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        width: 40%;
      }
    SCSS

    it { should report_lint line:2 }
  end

  context 'when allow_module_width is true and width is applied to module' do
    let(:linter_config) { {
      'module_name' => 'Foo',
      'allow_module_width' => true
    } }
    let(:scss) { <<-SCSS }
      .Foo {
        width: 40%;
      }
    SCSS

    it { should_not report_lint }
  end


end
