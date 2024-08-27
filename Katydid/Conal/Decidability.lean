-- A translation to Lean from Agda
-- https://github.com/conal/paper-2021-language-derivatives/blob/main/Decidability.lagda

import Katydid.Conal.Function

namespace Decidability

-- data Dec (A: Set l):Set l where
--   yes: A → Dec A
--   no :¬A → Dec A
class inductive Dec (P: Type u): Type u where
  | yes: P -> Dec P
  | no: (P -> PEmpty.{u}) -> Dec P

@[inline_if_reduce, nospecialize] def Dec.decide (P : Type) [h : Dec P] : Bool :=
  h.casesOn (fun _ => false) (fun _ => true)

abbrev DecPred {α : Type u} (r : α → Type) :=
  (a : α) → Dec (r a)

abbrev DecRel {α : Type u} (r : α → α → Type) :=
  (a b : α) → Dec (r a b)

abbrev DecEq (α : Type u) :=
  (a b : α) → Dec (a ≡ b)

-- module Symbolic {ℓ} {A : Set ℓ} (_≟_ : Decidable₂ {A = A} _≡_) where
def decEq {α : Type u} [inst : DecEq α] (a b : α) : Dec (a ≡ b) :=
  inst a b

-- ⊥? : Dec ⊥
-- ⊥? = no(𝜆())
def empty? : Dec PEmpty :=
  Dec.no (by intro; contradiction)

-- ⊤‽  : Dec ⊤
-- ⊤‽  = yes tt
def unit? : Dec PUnit :=
  Dec.yes PUnit.unit

-- _⊎‽_  : Dec A → Dec B → Dec (A ⊎ B)
-- no ¬a  ⊎‽ no ¬b  = no [ ¬a , ¬b ]
-- yes a  ⊎‽ no ¬b  = yes (inj₁ a)
-- _      ⊎‽ yes b  = yes (inj₂ b)
def sum? (a: Dec α) (b: Dec β): Dec (α ⊕ β) :=
  match (a, b) with
  | (Dec.no a, Dec.no b) =>
    Dec.no (fun ab =>
      match ab with
      | Sum.inl sa => a sa
      | Sum.inr sb => b sb
    )
  | (Dec.yes a, Dec.no _) =>
    Dec.yes (Sum.inl a)
  | (_, Dec.yes b) =>
    Dec.yes (Sum.inr b)

-- _×‽_  : Dec A → Dec B → Dec (A × B)
-- yes a  ×‽ yes b  = yes (a , b)
-- no ¬a  ×‽ yes b  = no (¬a ∘ proj₁)
-- _      ×‽ no ¬b  = no (¬b ∘ proj₂)
def prod? (a: Dec α) (b: Dec β): Dec (α × β) :=
  match (a, b) with
  | (Dec.yes a, Dec.yes b) => Dec.yes (Prod.mk a b)
  | (Dec.no a, Dec.yes _) => Dec.no (fun ⟨a', _⟩ => a a')
  | (_, Dec.no b) => Dec.no (fun ⟨_, b'⟩ => b b')

-- _✶‽ : Dec A → Dec (A ✶)
-- _ ✶‽ = yes []
def list?: Dec α -> Dec (List α) :=
  fun _ => Dec.yes []

-- map′ : (A → B) → (B → A) → Dec A → Dec B
-- map′ A→B B→A (yes a) = yes (A→B a)
-- map′ A→B B→A (no ¬a) = no (¬a ∘ B→A)
def map' (ab: A -> B) (ba: B -> A) (deca: Dec A): Dec B :=
  match deca with
  | Dec.yes a =>
    Dec.yes (ab a)
  | Dec.no nota =>
    Dec.no (nota ∘ ba)

-- map‽⇔ : A ⇔ B → Dec A → Dec B
-- map‽⇔ A⇔B = map′ (to ⟨$⟩_) (from ⟨$⟩_) where open Equivalence A⇔B
def map? (ab: A <=> B) (deca: Dec A): Dec B :=
  map' ab.toFun ab.invFun deca

-- _▹_ : A ↔ B → Dec A → Dec B
-- f ▹ a? = map‽⇔ (↔→⇔ f) a?
def apply (f: A <=> B) (deca: Dec A): Dec B :=
  map? f deca

-- _◃_ : B ↔ A → Dec A → Dec B
-- g ◃ a? = ↔Eq.sym g ▹ a?
def apply' (f: B <=> A) (deca: Dec A): Dec B :=
  map? f.sym deca

end Decidability
