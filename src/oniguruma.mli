(** Bindings to K.Kosako's {{: https://github.com/kkos/oniguruma } Oniguruma }
    library. *)

type _ t
(** A regular expression. The phantom type parameter represents the encoding,
    so that regular expressions for different encodings may not be mixed. *)

exception Error of string
[@warn_on_literal_pattern]

module Encoding : sig
  type ascii
  (** A phantom type representing ASCII. *)

  type utf8
  (** A phantom type representing UTF-8. *)

  type _ t
  (** A character encoding, indexed by a phantom type parameter. *)

  val ascii : ascii t
  (** The ASCII encoding. *)

  val utf8 : utf8 t
  (** The UTF-8 encoding. *)
end
(** Character encodings. *)

module Options : sig
  type compile_time
  (** Compile-time options. *)

  val (<+>) : compile_time -> compile_time -> compile_time

  val compile_none : compile_time
  val singleline : compile_time
  val multiline : compile_time
  val ignorecase : compile_time
  val extend : compile_time
  val find_longest : compile_time
  val find_not_empty : compile_time
  val negate_singleline : compile_time
  val dont_capture_group : compile_time
  val capture_group : compile_time
  val word_is_ascii : compile_time
  val digit_is_ascii : compile_time
  val space_is_ascii : compile_time
  val posix_is_ascii : compile_time
  val text_segment_extended_grapheme_cluster : compile_time
  val text_segment_word : compile_time

  type search_time
  (** Search-time options. *)

  val (<|>) : search_time -> search_time -> search_time

  val search_none : search_time
  val not_begin_string : search_time
  val not_end_string : search_time
end

module Syntax : sig
  type t
  (** The regular expression dialect. *)

  val oniguruma : t
end
(** The syntax type. *)

module Region : sig
  type t
  (** The capture groups returned by a search or match. *)

  external length : t -> int = "ocaml_onig_region_length"
  (** [length region] gets the number of regions. *)

  external capture_beg : t -> int -> int = "ocaml_onig_capture_beg"
  (** [capture_beg region idx] gets the string position of the capture group at
      the index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)

  external capture_end : t -> int -> int = "ocaml_onig_capture_end"
  (** [capture_end region idx] gets the string position of the capture group at
      the index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)
end

external create
  : string -> Options.compile_time -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"
(** [create pattern options encoding syntax] creates a regex. *)

external search
  : 'enc t -> string -> int -> int -> Options.search_time -> Region.t option
  = "ocaml_onig_search"
(** [search regex string start range option] searches
    [String.sub string start range] for [regex]. Raises {!exception:Error} if
    there is an error (other than a mismatch).

    @param regex The pattern to search for
    @param string The string to search
    @param start The string position to start searching from, as a byte offset
    @param range The string position to stop searching at, as a byte offset
    @param option Search options *)

external match_
  : 'enc t -> string -> int -> Options.search_time -> Region.t option
  = "ocaml_onig_match"
(** [match_ regex string pos options] matches [regex] against [string] at
    position [pos]. Raises {!exception:Error} if there is an error (other than
    a mismatch).

    @param regex The pattern to match
    @param string The string to match against
    @param pos The position of the string to match at, as a byte offset
    @param options Match options *)
