require 'test/unit'
require 'yaml'
require 'zaml'

class My_class
    def initialize
        @string = 'string...'
        @self = self
        @do_not_store_me = '*************** SHOULD NOT SHOW UP IN OUTPUT ***************'
        end
    def to_yaml_properties
        ['@string', '@self']
        end
    end
    
  
  #
  # This class and the test helper which follow embody what we mean by YAML compatibility.
  #     When we do a round-trip dump->load we expect
  #        1) that the data from ZAML.dump will come back correctly
  #            1a) all vales will be correct
  #            1b) only data that should be dumped is
  #            1c) object identity is preseved
  #        2) if YAML.dump also works by these standards the dumped data should 
  #           generally look like what yaml.rb produces, minus unneeded whitespace
  #           (trailing blanks, etc.)
  class Equivalency < Hash
      attr_reader :result,:message
      def self.test(a,b)
          new.test(a,b)
          end
      def test(a,b)
          @result = equivalent(a,b)
          self
          end
      def note_failure(msg)
          (@message ||= '') << msg
          false
          end
      def same_class(a,b)
          (a.class == b.class) or note_failure("Saw a #{a.class} but expected a #{b.class}\n")
          end
      def seen_either_before(a,b)
          result = (has_key?(a.object_id) or has_key?(b.object_id))
          (self[a.object_id] = self[b.object_id] = size) unless result or a.is_a? Numeric
          result
          end
      def matched_before(a,b)
          (self[a.object_id] == self[b.object_id]) or note_failure("#{a.inspect} and #{b.inspect} should refer to the same object.\n")
          end
      def same_object(a,b)
          a.object_id == b.object_id
          end
      def guess_maping(a,b)
          result = {}
          a.delete_if { |xa| result[xa] = b.delete(xa) }
          raise "Too many odd keys in a test hash to tell if the results are correct." if a.length > 1
          a.each      { |xa| result[xa] = b.pop }
          result
          end
      def same_properties(a,b)
          @what_we_are_looking_at ||= []
          return true if @what_we_are_looking_at.include? [a.object_id,b.object_id]
          @what_we_are_looking_at.push [a.object_id,b.object_id]
          result = case a
            when Array 
              (a.length == b.length) and a.zip(b).all? { |ia,ib| equivalent(ia,ib) }
            when Hash 
              key_map = guess_maping(a.keys,b.keys)
              a.keys.length == b.keys.length and a.keys.all? {|a_k|
                   b_k = key_map[a_k]
                   equivalent(a_k,b_k) and equivalent(a[a_k],b[b_k])
                   }
            when Exception
              equivalent(a.message,b.message)
            when Time,Date,Numeric,nil,true,false,Range,Symbol,String,Regexp
              a == b
            else
              a.to_yaml_properties.all? { |p| equivalent(a.instance_variable_get(p),b.instance_variable_get(p)) }
            end or note_failure("Expected:\n #{b.inspect}\n but got:\n #{a.inspect}\n")
          @what_we_are_looking_at.pop
          result
          end 
      def equivalent(a,b)
          seen_either_before(a,b) ? matched_before(a,b) : (same_object(a,b) or (same_class(a,b) and same_properties(a,b)))
          end
      end
      
      
def stripped(x)
    x.gsub(/ +$/,'').chomp.chomp.gsub(/\n+/,"\n")
    end
def dump_test(obj)
    z_load = YAML.load(z_dump = ZAML.dump(obj)) rescue "ZAML produced something YAML can't load."
    y_load = YAML.load(y_dump = YAML.dump(obj)) rescue "YAML failed to eat it's own dogfood"
    context = {}
    test = Equivalency.test(z_load,obj)
    assert_block("Reload discrepancy:\n#{test.message}\nZAML:\"\n#{z_dump}\"\nYAML:\"\n#{y_dump}\"\n\n") { test.result }
#         if Equivalency.test(y_load,obj).result and not obj.is_a? String
#             assert_equal stripped(y_dump),stripped(z_dump), "Dump discrepancy"
#             end
    end
