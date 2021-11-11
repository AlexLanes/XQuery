xquery version "1.0" encoding "utf-8";

(:: Language = "PT-BR"
Funções principais removidas desse link: https://github.com/abarax/xquery-utilities/blob/master/base64-encode-decode.xq
1.0 Alex Lanes - Criado local:encode-to-base64, local:base64-to-xml, local:base64-to-string
::)

declare variable $encode as xs:integer* external;
declare variable $decode as xs:string external;
declare variable $input as xs:string external;

(: Recebe a string codificado para ASCII(CodePoints) e converte para o valor da base64 em ASCII :)
declare function local:base64-encode($encode as xs:integer*) as xs:integer* {
    
    let $table := ( 65 to  90,  (: A-Z :)
                    97 to 122,  (: a-z :)
                    48 to  57,  (: 0-9 :)
                    43, 47 )    (: + / :)
                    
    for $byte0 at $p in $encode
    where $p mod 3 = 1
    return
      let $byte1 as xs:integer? := $encode[$p + 1]
      let $byte2 as xs:integer? := $encode[$p + 2]

      (: Convert the three bytes into four characters :)
      let $c0 := $table[$byte0 idiv 4 +1]
      let $c1 := $table[sum((($byte0 mod 4)*16, $byte1 idiv 16)) +1]
      let $c2 := if (empty($byte1)) then 61 (: pad with = :)
                 else $table[sum((($byte1 mod 16)*4, $byte2 idiv 64)) + 1]
      let $c3 := if (empty($byte2)) then 61 (: pad with = :)
                 else $table[$byte2 mod 64 + 1]
      return ($c0, $c1, $c2, $c3)
  
};

(: Recebe a string, a converte para CodePoints(ASCII), envia os CodePoints para local:base64-encode, recebe os CodePoints da base64 e
converte esses CodePoints para string do base64 :)
declare function local:encode-to-base64($string as xs:string) as xs:string {
  
  let $integersCodePoints       :=  fn:string-to-codepoints($string)
  let $base64-encode            :=  local:base64-encode($integersCodePoints)
    return
  fn:codepoints-to-string($base64-encode)
  
};


(:-------------------  Encode Acima   -------------------:)
(:-------------------  Decode Abaixo  -------------------:)


(: Recebe base64 como string, são codificados em ASCII(CodePoints) :)
declare function local:base64-decode($base64 as xs:string) as xs:integer* {
    let $codepoints :=  string-to-codepoints($base64) 
    let $table := ( 65 to  90,  (: A-Z :)
                    97 to 122,  (: a-z :)
                    48 to  57,  (: 0-9 :)
                    43, 47 )    (: + / :)
    return
    for $ch at $p in $codepoints
    where $p mod 4 = 1
    return
      let $c0 as xs:integer? := (index-of($table, $ch) - 1)
      let $c1 as xs:integer? := (index-of($table, $codepoints[$p + 1]) - 1)
      let $c2 as xs:integer? := (index-of($table, $codepoints[$p + 2]) - 1)
      let $c3 as xs:integer? := (index-of($table, $codepoints[$p + 3]) - 1)
      
      (: Convert the three bytes into four characters :)
      let $byte0 := ($c0 * 4) + ($c1 idiv 16)
      
      let $byte1 := (($c1 mod 16) * 16) +  ($c2 idiv 4)  
      
      let $byte2 := ($c2 mod 4) * 64 + ($c3 mod 64)
                 
      return ($byte0, $byte1, $byte2)
};

(: $base64 = PHJvb3QtZWxlbWVudD5PbGEgcGFyYSB2b2NlIGRvIGZ1dHVybzwvcm9vdC1lbGVtZW50Pg== :)
(: Recebe a base64 como string, a envia para local:base64-decode, retorna convertido em CodePoints(ASCII)
que é transformado em string e retornado como inlinedXML :)
declare function local:base64-to-xml($base64 as xs:string) as element()* {

        let $decoded := local:base64-decode($base64)
        let $stringCodepoints := fn:codepoints-to-string($decoded)
          return
        fn-bea:inlinedXML($stringCodepoints)
};

(: $base64 = TWFu = 77 97 110 = Man :)
(: Recebe a base64 como string, a envia para local:base64-decode, retorna convertido em CodePoints(ASCII)
que é transformado em string :)
declare function local:base64-to-string($base64 as xs:string) as xs:string {

        let $decoded := local:base64-decode($base64)
        let $stringCodepoints := fn:codepoints-to-string($decoded)
          return
        $stringCodepoints
};

(: Chamar a função desejada :)
local:base64-to-string($input)
