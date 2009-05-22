require File.dirname(__FILE__)+'/test_helper'

class ZamlDumpTest < Test::Unit::TestCase

    #
    # dump tests
    #
      
    def test_dump_object
        dump_test(Object.new)
        dump_test(My_class.new)
        end
      
    def test_dump_nil
        dump_test(nil)
        end
      
    def test_dump_symbol
        dump_test(:sym)
        end
      
    def test_dump_true
        dump_test(true)
        end
      
    def test_dump_false
        dump_test(false)
        end
      
    def test_dump_numeric
        dump_test(1)
        dump_test(1.1)
        end
      
    def test_dump_exception
        dump_test(Exception.new('error message'))
        dump_test(ArgumentError.new('error message'))
        end
      
    def test_dump_regexp
        dump_test(/abc/)
        dump_test(/a.*(b+)/im)
        end
      

    def test_dump_short_strings
        #
        every_character = (0..255).collect { |n| n.chr }
        letters = 'a'..'z'
        some_characters = (0..128).collect { |n| n.chr } - ('A'..'Z').to_a - ('b'..'z').to_a - ('1'..'9').to_a
        fewer_characters = some_characters - every_character[1..31] + ["\n","\r","\t","\e"] - [127.chr,128.chr]
        #
        every_character.each { |c1| dump_test c1 }
        every_character.each { |c1| dump_test "> "+c1 }
        every_character.each { |c1| every_character.each { |c2| dump_test c1+c2 }} 
        letters.each { |c1| 
            letters.each { |c2| 
                print c1,c2,' ',8.chr*3
                STDOUT.flush
                letters.each { |c3|
                    dump_test c1+c2+c3
                    letters.each { |c4| dump_test c1+c2+c3+c4 }
                    }
                }
            GC.start
            } if false  #slow
        some_characters.each { |c1| 
            some_characters.each { |c2|
                print((c1+c2).inspect,'        ',8.chr*((c1+c2).inspect.length+8))
                STDOUT.flush
                some_characters.each { |c3|
                    some_characters.each { |c4| dump_test c1+c2+c3+c4 }
                    }
                GC.start
                } 
            } if false #slower
        fewer_characters.each { |c1| 
            fewer_characters.each { |c2|
                print((c1+c2).inspect,'        ',8.chr*((c1+c2).inspect.length+8))
                STDOUT.flush
                fewer_characters.each { |c3|
                    fewer_characters.each { |c4|
                        fewer_characters.each { |c5| dump_test c1+c2+c3+c4+c5 }
                        }
                    GC.start
                    } 
                } 
            } if false #very slow
        end
    def test_system_dict_words
        system_dict = '/usr/share/dict/words'
        File.readlines(system_dict).each { |w| dump_test w.chomp } if File.exists?(system_dict)
        end
    def test_dump_tricky_strings
        dump_test("")
        dump_test("#")
        dump_test("!")
        dump_test("~")
        dump_test("=")
        dump_test("\n")
        dump_test("\n0")
        dump_test("\n!")
        dump_test("!\n")
        dump_test("##")
        dump_test("###")
        dump_test("2:7")
        dump_test("1:1 x")
        dump_test(">")
        dump_test(">>")
        dump_test("> >")
        dump_test("> !")
        dump_test(">++ !")
        dump_test(">0+ !")
        dump_test("| |")
        dump_test("0:0")
        dump_test("1:2:3")
        dump_test("+1:2:3")
        dump_test("1:-2:+3")
        dump_test("%.:.")
        dump_test("%.:/")
        end
    def test_dump_string
        dump_test('str')
        dump_test("   leading and trailing whitespace   ")
    
        dump_test("a string \n with newline")
        dump_test("a string with 'quotes'")
        dump_test("a string with \"double quotes\"")
        dump_test("a string with \\ escape")
        
        dump_test("a really long string" * 10)
        dump_test("a really long string \n with newline" * 10)
        dump_test("a really long string with 'quotes'" * 10)
        dump_test("a really long string with \"double quotes\"" * 10)
        dump_test("a really long string with \\ escape" * 10)
        
        dump_test("string with binary data \x00 \x01 \x02")
        dump_test("   funky\n test\n")
        dump_test('"')
        dump_test("'")
        dump_test('\\')
        dump_test("k: v")
        dump_test(":goo")
        dump_test("? foo")
        dump_test("{khkjh}")
        dump_test("[ha]")
        dump_test("- - (text) - -")
        dump_test("\n\n \n  \n   x\n  y\n z\n!\n")
        end
    
    def test_dump_strings_that_resemble_literals
        dump_test("true")
        dump_test("false")
        dump_test("null")
        dump_test("yes")
        dump_test("no")
        dump_test("on")
        dump_test("off")
        dump_test("nil")
        dump_test("3")
        dump_test("3.14")
        dump_test("1e-6")
        dump_test("0x345")
        dump_test("-0x345")
        dump_test("1e5")
        end
      
    def test_dump_time
        dump_test(Time.now)
        end
      
    def test_dump_date
        dump_test(Date.strptime('2008-08-08'))
        end
      
    def test_dump_range
        dump_test(1..10)
        dump_test('a'...'b')
        end
      
    #
    # hash
    #
      
    def test_dump_simple_hash
        dump_test({:key => 'value'})
        end
      
    HASH = {
        :nil => nil,
        :sym => :value, 
        :true => true,
        :false => false,
        :int => 100,
        :float => 1.1,
        :regexp => /abc/,
        'str' => 'value', 
        :range => 1..10
        }
      
    ARRAY = [nil, :sym, true, false, 100, 1.1, /abc/, 'str', 1..10]
      
    def test_dump_hash
        dump_test(HASH)
        end
      
    def test_dump_simple_nested_hash
        dump_test({:hash => {:key => 'value'}, :array => [1,2,3]})
        end
      
    def test_dump_nested_hash
        dump_test(HASH.merge(:hash => {:hash => {:key => 'value'}}, :array => [[1,2,3]]))
        end
      
    def test_dump_self_referential_hash
        array = ARRAY + [ARRAY]
        dump_test(HASH.merge(:hash => HASH, :array => array))
        end
      
    def test_dump_singlular_self_referential_hash
        hash = {}
        hash[hash] = hash
        dump_test(hash)
        end
      
    #
    # array
    #
      
    def test_dump_simple_array
        dump_test([1,2,3])
        end
       
    def test_dump_array
        dump_test(ARRAY)
        end
      
    def test_dump_simple_nested_array
        dump_test([{:key => 'value'}, [1,2,3]])
        end
      
    def test_dump_nested_array
        dump_test(ARRAY.concat([{:array => [1,2,3]}, [[1,2,3]]]))
        end
      
    def test_dump_self_referential_array
        array = ARRAY + [ARRAY, HASH.merge(:hash => HASH)]
        dump_test(array)
        end
      
    def test_dump_singlular_self_referential_array
        array = []
        array << array
        dump_test(array)
        end
      
    #
    # dump various data tests
    #
      
    my_range = 7..13
    my_obj = My_class.new
    my_dull_object = Object.new
    my_bob = 'bob'
    my_exception = Exception.new("Error message")
    my_runtime_error = RuntimeError.new("This is a runtime error exception")
    wright_joke = %q{
    
        I was in the grocery store. I saw a sign that said "pet supplies". 
    
        So I did.
    
        Then I went outside and saw a sign that said "compact cars".
    
        -- Steven Wright
        }
    a_box_of_cheese = [:cheese]
    DATA = [1, my_range, my_obj, my_bob, my_dull_object, 2, 'test', "   funky\n test\n", true, false, 
        {my_obj => 'obj is the key!'}, 
        {:bob => 6.8, :sam => 9.7, :subhash => {:sh1 => 'one', :sh2 => 'two'}}, 
        6, my_bob, my_obj, my_range, 'bob', 1..10, 0...8]
    MORE_DATA = [{
        :a_regexp => /a.*(b+)/im,
        :an_exception => my_exception,
        :a_runtime_error => my_runtime_error, 
        :a_long_string => wright_joke}
        ]
    NESTED_ARRAYS = [
        [:one, 'One'],
        [:two, 'Two'],
        a_box_of_cheese,
        [:three, 'Three'],
        [:four, 'Four'],
        a_box_of_cheese,
        [:five, 'Five'],
        [:six, 'Six']
        ]
    COMPLEX_DATA = {
        :data => DATA,
        :more_data => MORE_DATA,
        :nested_arrays => NESTED_ARRAYS
        }
    def test_dump_DATA
        dump_test(DATA)
        end
    def test_dump_MORE_DATA
        dump_test(MORE_DATA)
        end
    def test_dump_NESTED_ARRAYS
        dump_test(NESTED_ARRAYS)
        end
    def test_dump_COMPLEX_DATA
        dump_test(COMPLEX_DATA)
        end
    def test_indentation_array_edge_cases
        dump_test({[]=>[]})
        dump_test([[]])
        dump_test([[[],[]]])
        end
    def test_string_identity
        a = 'str'
        dump_test([a,a])
        end
    #
    #label configuration
    #
    def test_labels_on
        set_defaults :use_labels => true
        result = ZAML.dump( {"data"=>(1..2).map{|i|{"a"=>i,"b"=>i+1}}})
        expected= "--- 
  data: 
    - &id001 a: 1
      &id002 b: 2
    - *id001: 2
      *id002: 3"
        assert result == expected, "expected \"#{expected}\" but was \"#{result}\""
        restore_defaults
        end
    def test_labels_off
        set_defaults :use_labels => false
        result = ZAML.dump( {"data"=>(1..2).map{|i|{"a"=>i,"b"=>i+1}}})
        expected= "--- 
  data: 
    - a: 1
      b: 2
    - a: 2
      b: 3"
        assert result == expected, "expected \"#{expected}\" but was \"#{result}\""
        restore_defaults
        end
    #
    # Indent config
    #
    def test_indent_2
        
        end
    end
