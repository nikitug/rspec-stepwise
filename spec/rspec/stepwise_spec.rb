RSpec.describe RSpec::Stepwise do
  it 'runs steps in an order' do
    order = []

    run do
      stepwise do
        step 'first' do
          order << 1
        end

        step 'second' do
          order << 2
        end

        step 'third' do
          order << 3
        end
      end
    end

    expect(order).to eq [1, 2, 3]
  end

  it 'does not run steps after failed one' do
    executions = []

    run do
      stepwise 'check pending' do
        step 'first' do
          executions << :first
        end

        step 'fail' do
          fail
        end

        step 'pending' do
          executions << :pending
        end
      end
    end

    expect(executions).not_to include :pending
  end

  it 'shares execution context across all steps' do
    instances = []

    run do
      stepwise 'check pending' do
        let(:obj) { [] }

        step 'first' do
          instances << obj
        end

        step 'second' do
          instances << obj
        end
      end
    end

    expect(instances[0].object_id).to eq instances[1].object_id
  end

  describe '#after' do
    it 'runs after all steps including failed' do
      executions = []

      run do
        stepwise 'check after' do
          step 'first' do
            executions << :first
          end

          step 'fail' do
            executions << :failed
            fail
          end

          after do
            executions << :after
          end
        end
      end

      expect(executions).to eq [:first, :failed, :after]
    end
  end

  describe '#on_fail' do
    it 'does not run if no fails' do
      executions = []

      run do
        stepwise 'check no fail runs' do
          step 'ok' do
          end

          on_fail do
            executions << :failed
          end
        end
      end

      expect(executions).not_to include :failed
    end

    it 'runs once if step failed' do
      executions = []

      run do
        stepwise 'check fail runs' do
          step 'ok' do
          end

          step 'fail' do
            fail
          end

          on_fail do
            executions << :failed
          end
        end
      end

      expect(executions).to include :failed
    end

    it 'runs in an order' do
      order = []

      run do
        stepwise 'check fail order' do
          step 'fail' do
            fail
          end

          on_fail do
            order << 1
          end

          on_fail do
            order << 2
          end
        end
      end

      expect(order).to eq [1, 2]
    end
  end
end
