open Printf;;

let rec range a b =
  if a > b then
    []
  else a :: range (a + 1) b;;

let sum lst = List.fold_left (+) 0 lst;;

let product lst = List.fold_left ( * ) 1 lst;;

let choose n k = (product @@ range (n - k + 1) n) / (product @@ range 1 k);;

let sort lst = List.sort compare lst;;

(* https://ocaml.org/learn/tutorials/99problems.html#Workingwithlists *)
let combinations k lst =
  let rec aux k acc emit = function
    | [] -> acc
    | h :: t ->
      if k = 1 then aux k (emit [h] acc) emit t else
        let new_emit x = emit (h :: x) in
        aux k (aux (k-1) acc new_emit t) emit t
  in
  let emit x acc = x :: acc in
  aux k [] emit lst;;

let print_ticket ticket = List.iter (printf "%3d") ticket;;

let readlines filename =
  let lines = ref [] in
  let file = open_in filename in
  try
    while true do
      lines := input_line file :: !lines
    done; !lines
  with End_of_file ->
    close_in file;
    List.rev !lines;;

let parse_ticket ticket =
  let split = Str.split @@ Str.regexp " +" in
  split ticket
  |> List.map int_of_string
  |> sort;;

let get_tickets filename =
  readlines filename
  |> List.map parse_ticket;;

let klass = 6;;
let end_number = 49;;
let numbers = range 1 end_number;;
let ks_prices = [(3, 10); (4, 100); (5, 100_000); (6, 1_000_000)];;
let win_ks = List.rev @@ sort @@ List.map fst ks_prices;;

(* NOTE: does not guarantee uniqueness e.g.
          [0] = [0; 0; 0] = [0; 0; 0; 0] = []
         the order of the elements matters e.g.
          [1; 2; 3; 4] <> [4; 3; 2; 1]
         generation of IDs is based on
          https://en.wikipedia.org/wiki/Positional_notation
*)
let rec get_comb_id cb =
  let rec pow m n =
    if n = 0 then 1
    else m * pow m (n - 1) in
  match cb with
  | [] -> 0
  | h :: t -> h * pow end_number ((List.length cb) - 1)
              + get_comb_id t;;

let load_combinations filename =
  let combs = Hashtbl.create 0 in
  let add_comb c =
    let comb_id = get_comb_id c in
    (if Hashtbl.mem combs comb_id then
      succ @@ Hashtbl.find combs comb_id
    else 1)
    |> Hashtbl.replace combs comb_id in
  let add_ticket t =
    List.iter (fun k ->
      List.iter add_comb (combinations k t)) win_ks in
  get_tickets filename
  |> List.iter add_ticket;
  combs;;

let played_comb = load_combinations Sys.argv.(1);;

let ticket_price ticket =
  let get_comb_val c =
    let comb_id = get_comb_id c in
    if Hashtbl.mem played_comb comb_id then
      Hashtbl.find played_comb comb_id
    else 0 in
  let rec rm_dup_wins lst =
    match lst with
    | [] -> []
    | (k, n) :: t -> (k, n) :: (rm_dup_wins
                     @@ List.map (fun (k', n') ->
                                  (k', n' - n * choose k k')) t) in
  let price lst = sum @@ List.map (fun (k, n) ->
                    n * List.assoc k ks_prices) lst in
  List.map (fun k ->
    (k, sum @@ List.map get_comb_val (combinations k ticket))) win_ks
  |> rm_dup_wins
  |> price;;

let get_write_comb basename_fmt limit =
  let i = ref 0 in
  let n = ref 1 in
  let filename = ref (sprintf basename_fmt !n) in
  let out_ch = ref (open_out !filename) in
  let write_comb comb_str =
    let write_it =
      output_string !out_ch comb_str;
      flush !out_ch;
      i := !i + 1 in
    if !i >= limit then begin
      close_out !out_ch;
      n := !n + 1;
      i := 0;
      filename := sprintf basename_fmt !n;
      out_ch := open_out !filename;
      write_it
    end
    else write_it in
    write_comb;;

let comb_to_string comb =
  String.concat " " @@ List.map string_of_int comb;;

let write_combinations k lst write_fun =
  let rec cb k lst c =
    if k > (List.length lst) then ()
    else
      match k, lst with
      | 1, _ -> List.iter (fun e -> write_fun (e :: c)) lst
      | _, h :: t -> cb (k - 1) t (h :: c);
                     cb k t c in
  cb k lst [];;

let test_one () =
  combinations klass numbers
  |> List.map (fun t -> (ticket_price t, t))
  |> sort
  |> List.iter (fun (p, t) -> print_ticket t;
                              print_string " = ";
                              print_int p;
                              print_newline ());;

let test_two () =
  let write_comb = get_write_comb "combs_%d.txt" 998844 in
  write_combinations klass numbers (fun x -> write_comb @@ (comb_to_string x) ^ "\n");;

let test_three () =
  range 1 14
  |> List.map (sprintf "combs_%d.txt")
  |> List.iter (fun file ->
    get_tickets file
    |> List.iter (fun t ->
      print_int @@ ticket_price t;
      print_string " :";
      print_ticket t;
      print_newline ()));;

