RSpec.describe ArnoldCPM do
    before(:all) { ArnoldCPM.printer = Kernel }

    def expect_printed(*values)
        values.each do |value|
            expect(described_class.printer).to receive(:print).with(value, "\n")
        end
    end

    def expect_not_printed(*values)
        values.each do |value|
            expect(described_class.printer).to_not receive(:print).with(value, "\n")
        end
    end

    it "can print to stdout" do
        expect_printed 42, 33

        ArnoldCPM.totally_recall do
            its_showtime
                talk_to_the_hand 42
                talk_to_the_hand 33
            you_have_been_terminated
        end
    end

    it "can assign values to variables" do
        expect_printed 42

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 42
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end

    # Arithmetics

    it "supports addition" do
        expect_printed 22

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 20
                    get_up 2
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end

    it "supports subtraction" do
        expect_printed 18

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 20
                    get_down 2
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end

    it "supports multiplication" do
        expect_printed 40

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 20
                    youre_fired 2
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end
    
    it "supports division" do
        expect_printed 10

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 20
                    he_had_to_split 2
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end

    it "supports modulo division" do
        expect_printed 1

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 21
                    i_let_him_go 2
                enough_talk

                talk_to_the_hand _var
            you_have_been_terminated
        end
    end

    it "can use variables in calculations" do
        expect_printed 20

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _var
                    here_is_my_invitation 2
                enough_talk

                get_to_the_chopper _other
                    here_is_my_invitation 10
                enough_talk

                get_to_the_chopper _result
                    here_is_my_invitation _var
                    youre_fired _other
                enough_talk

                talk_to_the_hand _result
            you_have_been_terminated
        end 
    end 

    # Logical operations
    it "has two logical constants for true and false" do
        expect_printed 0, 1

        ArnoldCPM.totally_recall do
            its_showtime
                talk_to_the_hand i_lied
                talk_to_the_hand no_problemo
            you_have_been_terminated
        end 
    end

    it "can evaluate logical OR" do
        expect_printed 1, 0

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _result_1
                    here_is_my_invitation 1
                    consider_that_a_divorce i_lied
                enough_talk

                get_to_the_chopper _result_2
                    here_is_my_invitation 0
                    consider_that_a_divorce i_lied 
                enough_talk

                talk_to_the_hand _result_1
                talk_to_the_hand _result_2
            you_have_been_terminated
        end 
    end

    it "can evaluate logical AND" do
        expect_printed 1, 0

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _result_1
                    here_is_my_invitation 1
                    knock_knock no_problemo
                enough_talk

                get_to_the_chopper _result_2
                    here_is_my_invitation 0
                    knock_knock no_problemo 
                enough_talk

                talk_to_the_hand _result_1
                talk_to_the_hand _result_2
            you_have_been_terminated
        end 
    end

    # Comparison

    it "supports comparison operators" do
        expect_printed 1, 1

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _result_1
                    here_is_my_invitation 2
                    let_off_some_steam_bennet 1
                enough_talk

                get_to_the_chopper _result_2
                    here_is_my_invitation 4
                    you_are_not_you_you_are_me 4 
                enough_talk

                talk_to_the_hand _result_1
                talk_to_the_hand _result_2
            you_have_been_terminated
        end  
    end

    # Conditionals

    it "can evaluate if conditional statements" do
        expect_printed 1

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _condition
                    here_is_my_invitation no_problemo
                    consider_that_a_divorce i_lied
                enough_talk

                because_im_going_to_say_please _condition
                    talk_to_the_hand no_problemo
                you_have_no_respect_for_logic
            you_have_been_terminated
        end  
    end

    it "can evaluate if-else conditional statements" do
        expect_printed 0
        expect_not_printed 1

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _condition
                    here_is_my_invitation no_problemo
                    knock_knock i_lied
                enough_talk

                because_im_going_to_say_please _condition
                    talk_to_the_hand no_problemo
                bull_shit
                    talk_to_the_hand i_lied
                you_have_no_respect_for_logic
            you_have_been_terminated
        end  
    end

    it "can evaluate invested conditional statements" do
        expect_printed 22
        expect_not_printed 42, 0

        ArnoldCPM.totally_recall do
            its_showtime
                get_to_the_chopper _condition
                    here_is_my_invitation no_problemo
                    knock_knock 42
                enough_talk

                get_to_the_chopper _other_condition
                    here_is_my_invitation 44
                    you_are_not_you_you_are_me 33
                enough_talk

                because_im_going_to_say_please _condition
                    because_im_going_to_say_please _other_condition
                        talk_to_the_hand 42
                    bull_shit
                        talk_to_the_hand 22
                    you_have_no_respect_for_logic 
                bull_shit
                    talk_to_the_hand i_lied
                you_have_no_respect_for_logic
            you_have_been_terminated
        end  
    end

    # Function related

    it "can define void functions" do
        expect_printed 42
        expect_not_printed 28

        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _print
            i_need_your_clothes_your_boots_and_your_motorcycle _x
            i_need_your_clothes_your_boots_and_your_motorcycle _y
                talk_to_the_hand _x
                ill_be_back
                talk_to_the_hand _y
            hasta_la_vista_baby

            its_showtime
                get_to_the_chopper _x
                    here_is_my_invitation 42
                enough_talk
                get_to_the_chopper _y
                    here_is_my_invitation 28
                enough_talk

                do_it_now _print, _x, _y
            you_have_been_terminated
        end
    end

    it "can define custom functions, which can return values, with parameters" do
        expect_printed 70

        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _add
            i_need_your_clothes_your_boots_and_your_motorcycle _x
            i_need_your_clothes_your_boots_and_your_motorcycle _y
            give_these_people_air
                get_to_the_chopper _result
                    here_is_my_invitation _x
                    get_up _y
                enough_talk
                ill_be_back _result
            hasta_la_vista_baby

            its_showtime
                get_to_the_chopper _x
                    here_is_my_invitation 42
                enough_talk
                get_to_the_chopper _y
                    here_is_my_invitation 28
                enough_talk

                get_your_ass_to_mars _result
                do_it_now _add, _x, _y
                talk_to_the_hand _result
            you_have_been_terminated
        end
    end

    it "supports recursive function calls" do
        expect_printed 1, 2, 3, 4

        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _print_to_limit
            i_need_your_clothes_your_boots_and_your_motorcycle _number
            i_need_your_clothes_your_boots_and_your_motorcycle _limit
                talk_to_the_hand _number

                get_to_the_chopper _number_plus_one
                    here_is_my_invitation _number
                    get_up 1
                enough_talk

                get_to_the_chopper _condition
                    here_is_my_invitation _limit
                    let_off_some_steam_bennet _number_plus_one
                enough_talk

                because_im_going_to_say_please _condition
                    do_it_now _print_to_limit, _number_plus_one, _limit
                you_have_no_respect_for_logic
            hasta_la_vista_baby

            its_showtime
                do_it_now _print_to_limit, 1, 5
            you_have_been_terminated
        end
    end

    it "can evaluate function identity in equality comparison" do
        expect_printed 1, 0
        
        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _func
            i_need_your_clothes_your_boots_and_your_motorcycle _val
                talk_to_the_hand _val
            hasta_la_vista_baby

            listen_to_me_very_carefully _other
            i_need_your_clothes_your_boots_and_your_motorcycle _val
                talk_to_the_hand _val
            hasta_la_vista_baby

            its_showtime
                get_to_the_chopper _func_copy
                    here_is_my_invitation _func
                enough_talk
                get_to_the_chopper _another_func_copy
                    here_is_my_invitation _func
                enough_talk
                get_to_the_chopper _other_copy
                    here_is_my_invitation _other
                enough_talk

                get_to_the_chopper _same_functions
                    here_is_my_invitation _func_copy
                    you_are_not_you_you_are_me _another_func_copy
                enough_talk
                get_to_the_chopper _different_functions
                    here_is_my_invitation _func_copy
                    you_are_not_you_you_are_me _other_copy 
                enough_talk

                talk_to_the_hand _same_functions
                talk_to_the_hand _different_functions
            you_have_been_terminated
        end
    end

    it "can define invested functions" do
        expect_printed 42, 12

        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _outer
            give_these_people_air
                listen_to_me_very_carefully _inner
                i_need_your_clothes_your_boots_and_your_motorcycle _val
                    talk_to_the_hand _val
                hasta_la_vista_baby
                
                ill_be_back _inner
            hasta_la_vista_baby

            its_showtime
                get_your_ass_to_mars _func
                do_it_now _outer

                do_it_now _func, 42
                do_it_now _func, 12
            you_have_been_terminated
        end
    end
end

