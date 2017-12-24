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

    it "can calculate factorial" do
        expect_printed 120

        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _factorial 
            i_need_your_clothes_your_boots_and_your_motorcycle _n
            give_these_people_air
                get_to_the_chopper _is_equal_to_one
                    here_is_my_invitation 1
                    you_are_not_you_you_are_me _n
                enough_talk

                because_im_going_to_say_please _is_equal_to_one
                    ill_be_back 1
                you_have_no_respect_for_logic
                
                get_to_the_chopper _n_minus_one
                    here_is_my_invitation _n
                    get_down 1
                enough_talk

                get_your_ass_to_mars _res
                do_it_now _factorial, _n_minus_one

                get_to_the_chopper _factorial_n
                    here_is_my_invitation _n
                    youre_fired _res
                enough_talk

                ill_be_back _factorial_n 
            hasta_la_vista_baby

            its_showtime
                get_your_ass_to_mars _result
                do_it_now _factorial, 5
                talk_to_the_hand _result
            you_have_been_terminated
        end
    end

    it "can calculate fibonacci" do
        expect_printed 55
 
        ArnoldCPM.totally_recall do
            listen_to_me_very_carefully _fibonacci
            i_need_your_clothes_your_boots_and_your_motorcycle _n
            give_these_people_air
                get_to_the_chopper _is_less_than_two
                    here_is_my_invitation 2
                    let_off_some_steam_bennet _n
                enough_talk

                because_im_going_to_say_please _is_less_than_two
                    ill_be_back _n
                you_have_no_respect_for_logic

                get_to_the_chopper _n_take_one
                    here_is_my_invitation _n
                    get_down 1
                enough_talk
                get_your_ass_to_mars _fibonacci_n_take_one
                do_it_now _fibonacci, _n_take_one

                get_to_the_chopper _n_take_two
                    here_is_my_invitation _n
                    get_down 2
                enough_talk
                get_your_ass_to_mars _fibonacci_n_take_two
                do_it_now _fibonacci, _n_take_two

                get_to_the_chopper _fibonacci_n
                    here_is_my_invitation _fibonacci_n_take_one
                    get_up _fibonacci_n_take_two
                enough_talk
                ill_be_back _fibonacci_n
            hasta_la_vista_baby

            its_showtime
                get_your_ass_to_mars _fibonacci_20
                do_it_now _fibonacci, 10

                talk_to_the_hand _fibonacci_20
            you_have_been_terminated
        end
    end
end

