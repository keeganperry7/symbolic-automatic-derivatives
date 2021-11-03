Require Import CoqStock.Untie.

Class hashable (A : Type) :=
  {
    hash : A -> nat (* TODO: upgrade to Sint63 with Coq 8.14 *)
  }.

Lemma f_neq_to_neq
  : forall {A B: Type}
           (x y: A)
           (f: A -> B)
           (p: f x <> f y),
  x <> y.
Proof.
intros.
untie.
Qed.

Theorem hash_neq_to_neq
  : forall {A: Type}
           {h: hashable A}
           (x y: A)
           (p: hash x <> hash y),
  x <> y.
Proof.
intros.
untie.
Qed.