(** * Displayed category of varieties over a theory *)

Require Import UniMath.Foundations.All.

Require Import UniMath.Combinatorics.Vectors.

Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Univalence.
Require Import UniMath.CategoryTheory.categories.HSET.Core.
Require Import UniMath.CategoryTheory.categories.HSET.Univalence.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Require Import UniMath.CategoryTheory.DisplayedCats.SIP.

Require Import UniMath.Algebra.Universal.
Require Import UniMath.Algebra.Universal.HVectors.
Require Import UniMath.Algebra.Universal.Signatures.
Require Import UniMath.Algebra.Universal.Algebras.
Require Import UniMath.Algebra.Universal.Equations.
Require Import UniMath.Algebra.Universal.CatAlgebras.

Notation "'theory'" := eqsignature. (* isn't it a standard name? *)
Context (σ : theory).

Local Open Scope sorted.

Definition varieties_disp : disp_cat (shSet_category σ).
Proof.
  use disp_cat_from_SIP_data.
  - cbn; intro A.
    exact (∑ ops: (∏ nm: names σ, A ↑ (arity nm) → A (sort nm)),
            (∏ e : eqs σ, holds (make_algebra A ops) (geteq e))).
  - cbn. intros a b [opa iseqa] [opb iseqb] f.
    exact (@ishom σ (make_algebra a opa) (make_algebra b opb) f).
  - intros. apply isapropishom.
  - cbn. intros. apply ishomid.
  - cbn. intros A B C prpA prpB prpC. intros f g ishomf ishomg.
    exact (ishomcomp (make_hom ishomf) (make_hom ishomg)).
Defined.

Lemma is_univalent_varieties_disp : is_univalent_disp varieties_disp.
Proof.
  use is_univalent_disp_from_SIP_data.
  - cbn; intro A. apply isaset_total2.
    * apply impred_isaset. cbn; intro nm; use isaset_set_fun_space.
    * cbn; intros. apply impred_isaset. cbn; intro sys. apply impred_isaset; cbn. intro t.
      apply isasetaprop. apply A.
  - cbn; intros A [opA iseqA][op'A iseq'A]. intros i i'.
    use total2_paths2_f.
    * use funextsec. intro nm. use funextfun. intro v.
      unfold ishom in *. cbn in *. set (H1 := i nm v).
      eapply pathscomp0.
      exact H1.
      apply maponpaths.
      apply staridfun.
    * cbn. apply funextsec; cbn; intro e. apply funextsec; intro f. apply A.
Qed.

Definition category_varieties : category := total_category varieties_disp.

Lemma is_univalent_category_varieties : is_univalent category_varieties.
Proof.
  exact (@is_univalent_total_category (shSet_category σ) varieties_disp 
           (is_univalent_shSet_category σ) is_univalent_varieties_disp).
Qed.