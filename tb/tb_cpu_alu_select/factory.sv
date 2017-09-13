`ifndef FACTORY__SV
`define FACTORY__SV

typedef class factory ;
typedef class test_base;

virtual class proxy_base;
   pure virtual function  test_base   create_test() ; 
   pure virtual function  string  get_typename(); 
endclass 

class proxy_class #(type T=test_base, string Tname="T" ) extends proxy_base;
   typedef  proxy_class#(T,Tname)  this_type ; 
   static   string   type_name   =  Tname ; 
   static   this_type      me    =  get() ; 

   static   function this_type   get();
      factory  f  =  factory::get() ; 
      if ( me==null) begin 
         me =  new(); 
         f.register( me ) ; 
      end
      return me; 
   endfunction

   virtual function test_base  create_test(  ) ; 
      T  test_case ; 
      test_base   temp; 
      test_case   =  new(); 
      $cast(temp, test_case ) ; 
      return temp ;      
   endfunction

   virtual function string get_typename() ; 
      return type_name ; 
   endfunction
endclass

class factory;
   static   proxy_base  tests[string] ;
   static   factory     me = get() ; 

   static function factory get() ; 
      if ( me == null ) begin me =  new(); end 
      return me ; 
   endfunction 

   function void register( proxy_base proxy ) ; 
      tests[proxy.get_typename()]  =  proxy; 
   endfunction

   static function test_base create_test_by_name( string name ) ; 
      proxy_base proxy ;  
      if ( tests.exists(name) ) begin 
         proxy =  tests[name] ; 
         return proxy.create_test() ; 
      end else begin 
         return null;
      end
      
   endfunction 

   static function void print() ; 

      foreach ( tests[name] ) begin 
         $display(" %s = %s", name, tests[name].get_typename() ) ; 
      end 

   endfunction
endclass

`endif // FACTORY__SV
