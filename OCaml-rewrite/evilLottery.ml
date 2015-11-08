open Printf;;

let rec range a b =
  if a > b then
    []
  else a :: range (a + 1) b;;

let sum lst = List.fold_left (+) 0 lst;;

let product lst = List.fold_left ( * ) 1 lst;;

let choose n k = (product @@ range (n - k + 1) n) / (product @@ range 1 k);;

(* http://rosettacode.org/wiki/Combinations#OCaml *)
let rec combinations k lst =
  match k, lst with
  | 0, _      -> [[]]
  | _, []     -> []
  | k, h :: t -> List.map (fun x -> h :: x) (combinations (k - 1) t)
                 @ combinations k t;;

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
  |> List.sort compare;;

let get_tickets filename =
  readlines filename
  |> List.map parse_ticket;;

let klass = 6;;
let numbers = range 1 49;;
let ks_prices = [(3, 10); (4, 100); (5, 100_000); (6, 1_000_000)];;
let win_ks = List.rev @@ List.map fst ks_prices;;

let load_combinations filename =
  let combs = Hashtbl.create 0 in
  let add_comb c =
    (if Hashtbl.mem combs c then
      succ @@ Hashtbl.find combs c
    else 1)
    |> Hashtbl.replace combs c in
  let add_ticket t =
    List.iter (fun k ->
      List.iter add_comb (combinations k t)) win_ks in
  get_tickets filename
  |> List.iter add_ticket;
  combs;;

let played_comb = load_combinations Sys.argv.(1);;

let ticket_price ticket =
  let get_comb_val c =
    if Hashtbl.mem played_comb c then
      Hashtbl.find played_comb c
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

combinations klass numbers
|> List.map (fun t -> (ticket_price t, t))
|> List.sort compare
|> List.iter (fun (p, t) -> print_ticket t;
                            print_string " = ";
                            print_int p;
                            print_newline ());;

