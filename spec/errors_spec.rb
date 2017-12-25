RSpec.describe ArnoldCPM do
  before(:all) { ArnoldCPM.printer = Kernel }  

  context 'raises errors' do
    it 'if the main function is not declared' do
      code = proc {}
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        UndeclaredFunctionError,
        "Undeclared function '__main__' invoked."
      )
    end

    it 'if statement is defined outside the bounds of a function' do
      code = proc do 
        talk_to_the_hand 42
        its_showtime
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        OutOfBoundsError
      )
    end

    it 'if an undeclared variable is referenced' do
      code = proc do
        its_showtime
          talk_to_the_hand _var
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        UndeclaredVariableError,
        "Undeclared variable '_var' referenced."
      )
    end

    it 'if an uninitialized variable is used' do
      first_case = proc do
        its_showtime
          get_to_the_chopper _val
          enough_talk
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&first_case) }.to raise_error(
        UninitializedVariableError,
        "Uninitialized variable '_val' used."
      )

      second_case = proc do
        its_showtime
          get_to_the_chopper _val
            get_up 5
          enough_talk
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&second_case) }.to raise_error(
        UninitializedVariableError,
        "Uninitialized variable '_val' used."
      )
    end

    it 'if an undeclared function is invoked' do
      code = proc do
        its_showtime
          do_it_now _print, 42
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        UndeclaredFunctionError,
        "Undeclared function '_print' invoked."
      )
    end

    it 'if a function parameter does not receive a value' do
      code = proc do
        listen_to_me_very_carefully _print
        i_need_your_clothes_your_boots_and_your_motorcycle _val
          talk_to_the_hand _val
        hasta_la_vista_baby

        its_showtime
          do_it_now _print
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        UninitializedVariableError,
        "Uninitialized variable '_val' used."
      )
    end

    it 'if a non-void function does not return a value' do
      code = proc do
        listen_to_me_very_carefully _func
        give_these_people_air
        hasta_la_vista_baby

        its_showtime
          get_your_ass_to_mars _result
          do_it_now _func
        you_have_been_terminated
      end
      expect { ArnoldCPM.totally_recall(&code) }.to raise_error(
        FunctionDoesNotReturnError,
        "Non-void function '_func' does not return a result."
      )
    end
  end
end

