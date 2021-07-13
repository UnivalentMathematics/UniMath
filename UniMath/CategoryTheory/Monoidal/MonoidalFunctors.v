(** Monoidal functors *)

(** behaviour w.r.t. to swapped tensor products added by Ralph Matthes in 2019, then iso changed to z_iso in 2021 *)

Require Import UniMath.Foundations.PartD.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.PrecategoryBinProduct.
Require Import UniMath.CategoryTheory.Monoidal.MonoidalCategories.
Require Import UniMath.CategoryTheory.whiskering.

Local Open Scope cat.

Section Monoidal_Functor.

Context (Mon_C Mon_D : monoidal_precat).

Local Definition C := monoidal_precat_precat Mon_C.
Local Definition tensor_C := monoidal_precat_tensor Mon_C.
Notation "X ⊗_C Y" := (tensor_C (X , Y)) (at level 31).
Notation "f #⊗_C g" := (# tensor_C (f #, g)) (at level 31).
Local Definition I_C := monoidal_precat_unit Mon_C.
Local Definition α_C := monoidal_precat_associator Mon_C.
Local Definition λ_C := monoidal_precat_left_unitor Mon_C.
Local Definition ρ_C := monoidal_precat_right_unitor Mon_C.

Local Definition D := monoidal_precat_precat Mon_D.
Local Definition tensor_D := monoidal_precat_tensor Mon_D.
Notation "X ⊗_D Y" := (tensor_D (X , Y)) (at level 31).
Notation "f #⊗_D g" := (# tensor_D (f #, g)) (at level 31).
Local Definition I_D := monoidal_precat_unit Mon_D.
Local Definition α_D := monoidal_precat_associator Mon_D.
Local Definition λ_D := monoidal_precat_left_unitor Mon_D.
Local Definition ρ_D := monoidal_precat_right_unitor Mon_D.

Section Monoidal_Functor_Conditions.

Context (F : C ⟶ D).

Definition monoidal_functor_map_dom : precategory_binproduct C C ⟶ D :=
  functor_composite (pair_functor F F) tensor_D.

Lemma monoidal_functor_map_dom_ok: functor_on_objects monoidal_functor_map_dom =
  λ c, F (ob1 c) ⊗_D F (ob2 c).
Proof.
  apply idpath.
Qed.

Definition monoidal_functor_map_codom : precategory_binproduct C C ⟶ D :=
  functor_composite tensor_C F.

Lemma monoidal_functor_map_codom_ok: functor_on_objects monoidal_functor_map_codom =
  λ c, F (ob1 c ⊗_C ob2 c).
Proof.
  apply idpath.
Qed.

Definition monoidal_functor_map :=
  monoidal_functor_map_dom ⟹ monoidal_functor_map_codom.

Definition monoidal_functor_map_funclass (μ : monoidal_functor_map):
  ∏ x : ob (C ⊠ C),  monoidal_functor_map_dom x -->  monoidal_functor_map_codom x
  := pr1 μ.
Coercion monoidal_functor_map_funclass : monoidal_functor_map >-> Funclass.

Definition monoidal_functor_associativity (μ : monoidal_functor_map) :=
  ∏ (x y z : C),
  μ (x, y) #⊗_D id F(z) · μ (x ⊗_C y, z) · #F (α_C ((x, y), z))
  =
  α_D ((F x, F y), F z) · id (F x) #⊗_D μ (y, z) · μ (x, y ⊗_C z).

Definition monoidal_functor_unitality (ϵ : I_D --> F I_C) (μ : monoidal_functor_map) :=
  ∏ (x : C),
  (λ_D (F x) = ϵ #⊗_D (id (F x)) · μ (I_C, x) · #F (λ_C x))
  ×
  (ρ_D (F x) = (id (F x)) #⊗_D ϵ · μ (x, I_C) · #F (ρ_C x)).

End Monoidal_Functor_Conditions.

Definition lax_monoidal_functor : UU :=
  ∑ F : C ⟶ D, ∑ ϵ : I_D --> F I_C, ∑ μ : monoidal_functor_map F,
  (monoidal_functor_associativity F μ) × (monoidal_functor_unitality F ϵ μ).

Definition mk_lax_monoidal_functor (F : C ⟶ D) (ϵ : I_D --> F I_C)
  (μ : monoidal_functor_map F) (Hass: monoidal_functor_associativity F μ)
  (Hunit: monoidal_functor_unitality F ϵ μ): lax_monoidal_functor :=
  (F,, (ϵ,, (μ,, (Hass,, Hunit)))).

Definition strong_monoidal_functor : UU :=
  ∑ L : lax_monoidal_functor,
  (is_z_isomorphism (pr1 (pr2 L))) (* ϵ is an iso *)
  ×
  (is_nat_z_iso (pr1 (pr2 (pr2 L)))). (* μ is an iso *)

End Monoidal_Functor.

Definition strong_monoidal_functor_functor {Mon Mon' : monoidal_precat} (U : strong_monoidal_functor Mon Mon') := pr1 (pr1 U).
Coercion strong_monoidal_functor_functor : strong_monoidal_functor >-> functor.

Section swapped_tensor.

  Context {Mon Mon' : monoidal_precat}.

  Local Definition CC := monoidal_precat_precat Mon.
  Local Definition C' := monoidal_precat_precat Mon'.
  Local Definition tensor := monoidal_precat_tensor Mon.
  Local Definition tensor' := monoidal_precat_tensor Mon'.

Lemma swapping_of_lax_monoidal_functor_assoc (Fun: lax_monoidal_functor Mon Mon'):
    let F := pr1 Fun in let μ := pr1 (pr2 (pr2 Fun)) in
  monoidal_functor_associativity (swapping_of_monoidal_precat Mon) (swapping_of_monoidal_precat Mon') F
                                 (pre_whisker binswap_pair_functor μ).
Proof.
  induction Fun as [F [ϵ [μ [Hass Hunit]]]].
  red. intros x y z.
  set (Hass_inst := Hass z y x).
  apply pathsinv0. rewrite <- assoc.
  cbn.
  set (f := nat_z_iso_pointwise_z_iso (monoidal_precat_associator Mon') ((F z, F y), F x)).
  apply (z_iso_inv_on_right _ _ _ f).
  transparent assert (is : (is_z_isomorphism (# F (monoidal_precat_associator Mon ((z, y), x))))).
  { apply functor_on_is_z_isomorphism.
    apply monoidal_precat_associator.
  }
  set (Hass_inst' := z_iso_inv_on_left _ _ _ _ (_,, is) _ (! Hass_inst)).
  etrans.
  { exact Hass_inst'. }
  clear Hass_inst Hass_inst'.
  do 2 rewrite assoc.
  apply cancel_precomposition.
  apply idpath.
Qed.

Definition swapping_of_lax_monoidal_functor: lax_monoidal_functor Mon Mon' ->
  lax_monoidal_functor (swapping_of_monoidal_precat Mon)
                       (swapping_of_monoidal_precat Mon').
Proof.
  intro Fun.
  induction Fun as [F [ϵ [μ [Hass Hunit]]]].
  use mk_lax_monoidal_functor.
  - exact F.
  - exact ϵ.
  - exact (pre_whisker binswap_pair_functor μ).
  - apply (swapping_of_lax_monoidal_functor_assoc (F,, (ϵ,, (μ,, (Hass,, Hunit))))).
  - abstract ( red; intro x; induction (Hunit x) as [Hunit1 Hunit2]; split; assumption ).
Defined.

Definition swapping_of_strong_monoidal_functor: strong_monoidal_functor Mon Mon' ->
  strong_monoidal_functor (swapping_of_monoidal_precat Mon)
                          (swapping_of_monoidal_precat Mon').
Proof.
  intro Fun.
  induction Fun as [L [Hϵ Hμ]].
  apply (tpair _ (swapping_of_lax_monoidal_functor L)).
  split.
  - exact Hϵ.
  - exact (pre_whisker_on_nat_z_iso binswap_pair_functor (pr1 (pr2 (pr2 L))) Hμ).
Defined.

Lemma swapping_of_strong_monoidal_functor_on_objects (Fun: strong_monoidal_functor Mon Mon')(a: CC): swapping_of_strong_monoidal_functor Fun a = Fun a.
Proof.
  apply idpath.
Qed.

End swapped_tensor.
