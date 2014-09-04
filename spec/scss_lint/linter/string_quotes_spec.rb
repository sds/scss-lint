require 'spec_helper'

describe SCSSLint::Linter::StringQuotes do
  context 'when string is written with single quotes' do
    let(:css) { <<-CSS }
      p {
        content: 'hello';
      }
    CSS

    it { should_not report_lint }

    context 'and contains escaped single quotes' do
      let(:css) { <<-CSS }
        p {
          content: 'hello \\'world\\'';
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and contains single quotes escaped as hex' do
      let(:css) { <<-CSS }
        p {
          content: 'hello \\27world\\27';
        }
      CSS

      it { should_not report_lint }
    end

    context 'and contains double quotes' do
      let(:css) { <<-CSS }
        p {
          content: 'hello "world"';
        }
      CSS

      it { should_not report_lint }
    end

    context 'and contains interpolation' do
      let(:css) { <<-CSS }
        p {
          content: 'hello \#{$world}';
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when @import uses single quotes' do
    let(:css) { "@import 'file';" }

    it { should_not report_lint }

    context 'and has no trailing semicolon' do
      let(:css) { "@import 'file'\n" }

      it { should_not report_lint }
    end
  end

  context 'when @charset uses single quotes' do
    let(:css) { "@charset 'UTF-8';" }

    it { should_not report_lint }
  end

  context 'when string is written with double quotes' do
    let(:css) { <<-CSS }
      p {
        content: "hello";
      }
    CSS

    it { should report_lint line: 2 }

    context 'and contains escaped double quotes' do
      let(:css) { <<-CSS }
        p {
          content: "hello \\"world\\"";
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and contains double quotes escaped as hex' do
      let(:css) { <<-CSS }
        p {
          content: "hello \\22world\\22";
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and contains single quotes' do
      let(:css) { <<-CSS }
        p {
          content: "hello 'world'";
        }
      CSS

      it { should_not report_lint }
    end

    context 'and contains interpolation' do
      let(:css) { <<-CSS }
        p {
          content: "hello \#{$world}"
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when @import uses double quotes' do
    let(:css) { '@import "file";' }

    it { should report_lint }

    context 'and has no trailing semicolon' do
      let(:css) { '@import "file"' }

      it { should report_lint }
    end
  end

  context 'when @charset uses double quotes' do
    let(:css) { '@charset "UTF-8";' }

    it { should report_lint }
  end

  context 'when property has a literal identifier' do
    let(:css) { <<-CSS }
      p {
        display: none;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property is a URL with single quotes' do
    let(:css) { <<-CSS }
      p {
        background: url('image.png');
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property is a URL with double quotes' do
    let(:css) { <<-CSS }
      p {
        background: url("image.png");
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when the configuration has been set to prefer double quotes' do
    let(:linter_config) { { 'style' => 'double_quotes' } }

    context 'and string is written with single quotes' do
      let(:css) { <<-CSS }
        p {
          content: 'hello';
        }
      CSS

      it { should report_lint line: 2 }

      context 'and contains escaped single quotes' do
        let(:css) { <<-CSS }
          p {
            content: 'hello \\'world\\'';
          }
        CSS

        it { should report_lint line: 2 }
      end

      context 'and contains single quotes escaped as hex' do
        let(:css) { <<-CSS }
          p {
            content: 'hello \\27world\\27';
          }
        CSS

        it { should report_lint line: 2 }
      end

      context 'and contains double quotes' do
        let(:css) { <<-CSS }
          p {
            content: 'hello "world"';
          }
        CSS

        it { should_not report_lint }
      end

      context 'and contains interpolation' do
        let(:css) { <<-CSS }
          p {
            content: 'hello \#{$world}';
          }
        CSS

        it { should_not report_lint }
      end

      context 'and contains interpolation inside a substring with single quotes' do
        let(:css) { <<-CSS }
          p {
            content: "<svg width='\#{$something}'>";
          }
        CSS

        it { should_not report_lint }
      end

      context 'and contains a single-quoted string inside interpolation' do
        let(:css) { <<-CSS }
          p {
            content: "<svg width='\#{func('hello')}'>";
          }
        CSS

        it { should report_lint }
      end
    end

    context 'and string is written with double quotes' do
      let(:css) { <<-CSS }
        p {
          content: "hello";
        }
      CSS

      it { should_not report_lint }

      context 'and contains escaped double quotes' do
        let(:css) { <<-CSS }
          p {
            content: "hello \\"world\\"";
          }
        CSS

        it { should report_lint line: 2 }
      end

      context 'and contains double quotes escaped as hex' do
        let(:css) { <<-CSS }
          p {
            content: "hello \\22world\\22";
          }
        CSS

        it { should_not report_lint }
      end

      context 'and contains single quotes' do
        let(:css) { <<-CSS }
          p {
            content: "hello 'world'";
          }
        CSS

        it { should_not report_lint }
      end

      context 'and contains interpolation' do
        let(:css) { <<-CSS }
          p {
            content: "hello \#{$world}";
          }
        CSS

        it { should_not report_lint }
      end
    end

    context 'when property has a literal identifier' do
      let(:css) { <<-CSS }
        p {
          display: none;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when property is a URL with single quotes' do
      let(:css) { <<-CSS }
        p {
          background: url('image.png');
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when property is a URL with double quotes' do
      let(:css) { <<-CSS }
        p {
          background: url("image.png");
        }
      CSS

      it { should_not report_lint }
    end
  end
end
