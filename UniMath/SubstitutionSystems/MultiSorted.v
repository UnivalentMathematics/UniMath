(**

Definition of multisorted binding signatures.

Written by: Anders Mörtberg, 2016

*)

Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Sets.
Require Import UniMath.Foundations.Combinatorics.Lists.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.limits.products.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.limits.coproducts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.FunctorAlgebras.
Require Import UniMath.CategoryTheory.exponentials.
Require Import UniMath.CategoryTheory.CocontFunctors.
Require Import UniMath.CategoryTheory.Monads.
Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.category_hset_structures.
Require Import UniMath.CategoryTheory.HorizontalComposition.

Require Import UniMath.SubstitutionSystems.Signatures.
Require Import UniMath.SubstitutionSystems.SignatureExamples.
Require Import UniMath.SubstitutionSystems.SumOfSignatures.
Require Import UniMath.SubstitutionSystems.BinProductOfSignatures.
Require Import UniMath.SubstitutionSystems.SubstitutionSystems.
Require Import UniMath.SubstitutionSystems.LiftingInitial.
Require Import UniMath.SubstitutionSystems.MonadsFromSubstitutionSystems.
(* Require Import UniMath.SubstitutionSystems.Notation. *)

Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).

Section DiscreteCategory.

Variable (A : UU).

Definition DiscPrecat_data : precategory_data.
Proof.
mkpair.
- apply (A,,paths).
- mkpair; [ apply idpath | apply @pathscomp0 ].
Defined.

Definition is_precategory_DiscPrecat_data : is_precategory DiscPrecat_data.
Proof.
split; [split|]; trivial; intros.
+ apply pathscomp0rid.
+ apply path_assoc.
Qed.

Definition DiscPrecat : precategory :=
  (DiscPrecat_data,,is_precategory_DiscPrecat_data).

Lemma has_homsets_DiscPrecat (H : isofhlevel 3 A) : has_homsets DiscPrecat.
Proof.
intros ? ? ? ? ? ?; apply H.
Qed.

End DiscreteCategory.

(** * Definition of multisorted binding signatures *)
Section MBindingSig.

Variable (sort : UU).
Variable (eq : isdeceq sort). (* Can we eliminate this assumption? *)

Let sort_cat : precategory := DiscPrecat sort.
Let sortToHSET : precategory := [sort_cat,HSET,has_homsets_HSET].

Lemma has_homsets_sortToHSET : has_homsets sortToHSET.
Proof.
apply functor_category_has_homsets.
Qed.

Local Definition BinProductsSortToHSETToHSET : BinProducts [sortToHSET,HSET,has_homsets_HSET].
Proof.
apply (BinProducts_functor_precat _ _ BinProductsHSET).
Defined.

Local Definition CoproductsSortToHSET I (hI : isaset I) : Coproducts I sortToHSET.
Proof.
now apply Coproducts_functor_precat, Coproducts_HSET.
Defined.

Local Definition CoproductsSortToHSET2 I (hI : isaset I) :
  Coproducts I [sortToHSET, sortToHSET, has_homsets_sortToHSET].
Proof.
now apply Coproducts_functor_precat, CoproductsSortToHSET.
Defined.

Definition mk_sortToHSET (f : sort → hSet) : sortToHSET.
Proof.
mkpair.
+ apply (tpair _ f).
  intros a b hab; simpl; apply (transportf f hab).
+ abstract (now split; [ intros a; apply idpath | intros a b c [] [] ]).
Defined.

(* Coercion sortToHsetToFun (s : sortToHSET) : sort → HSET := pr1 s. *)

Definition MSig : UU :=
  Π (s : sort), Σ (I : UU), I → list (list sort × sort).

Definition indices (M : MSig) : sort → UU := fun s => pr1 (M s).

Definition args (M : MSig) (s : sort) : indices M s → list (list sort × sort) :=
  pr2 (M s).


Local Notation "'1'" := (TerminalHSET).
Local Notation "a ⊕ b" := (BinCoproductObject _ (BinCoproductsHSET a b)) (at level 50).

(* Definition option : sort -> sortToHSET -> sortToHSET. *)
(* Proof. *)
(* intros s f. *)
(* apply mk_sortToHSET; intro t. *)
(* induction (eq s t) as [H|H]. *)
(* - apply (pr1 f t ⊕ 1). (* TODO: Can one add a coercion to make this look like sort -> Set *) *)
(* - apply (pr1 f t). *)
(* Defined. *)

Definition option_functor (s : sort) : functor sortToHSET sortToHSET.
Proof.
mkpair.
- mkpair.
+ intro f.
apply mk_sortToHSET; intro t.
induction (eq s t) as [H|H].
* apply (pr1 f t ⊕ 1). (* TODO: Can one add a coercion to make this look like sort -> Set *)
* apply (pr1 f t).
+
intros F G α.
mkpair.
* simpl; intro t.
induction (eq s t) as [p|p]; simpl; clear p.
{ apply (coprodf (α t) (idfun unit)). }
{ apply α. }
* intros t1 t2 []; apply idpath.
-
simpl.
split.
+ intros F; simpl in *.
apply subtypeEquality; [intro x; apply (isaprop_is_nat_trans _ _ has_homsets_HSET)|].
simpl.
apply funextsec; intro t.
induction (eq s t) as [p|p]; trivial; simpl; clear p.
now apply funextfun; intros [].
+
intros F G H αFG αGH; simpl in *.
apply subtypeEquality; [intro x; apply (isaprop_is_nat_trans _ _ has_homsets_HSET)|].
simpl.
apply funextsec; intro t.
induction (eq s t) as [p|p]; trivial; simpl; clear p.
now apply funextfun; intros [].
Defined.

Definition option_list (xs : list sort) : functor sortToHSET sortToHSET.
Proof.
use (foldr _ _ xs).
+ intros s F.
  apply (functor_composite (option_functor s) F).
+ apply functor_identity.
Defined.

Definition sortToHSETToHSET (s : sort) : functor sortToHSET HSET.
Proof.
mkpair.
+ mkpair.
  - intro f; apply (pr1 f s).
  - simpl; intros a b f H; apply (f s H).
+ abstract (split;
    [ now intros f; apply funextsec
    | now intros f g h fg gh; apply funextsec; intro x ]).
Defined.

(* Definition sortToHSETToHSet' : [sortToHSET, sortToHSET, has_homsets_sortToHSET]. *)
(* Proof. *)
(* mkpair. *)
(* + mkpair. *)
(*   admit. *)
(*   admit. *)
(* + admit. *)
(* Admitted. *)

Definition endo_fun (X : functor sortToHSET sortToHSET) (a : list sort × sort) : functor sortToHSET HSET.
Proof.
set (O := functor_composite (option_list (pr1 a)) X).
apply (functor_composite O (sortToHSETToHSET (pr2 a))).
Defined.

Lemma endo_fun_functor (a : list sort × sort) :
  functor [sortToHSET,sortToHSET,has_homsets_sortToHSET] [sortToHSET,HSET,has_homsets_HSET].
Proof.
mkpair.
- mkpair.
  + intro X.
    apply (endo_fun X a).
  + intros F G α.
unfold endo_fun.
set (F1 := functor_composite (option_list (pr1 a)) F : functor sortToHSET sortToHSET).
set (F1' := functor_composite (option_list (pr1 a)) G : functor sortToHSET sortToHSET).
set (F2 := sortToHSETToHSET (pr2 a)).
apply (@hor_comp _ _ _ F1 F1' F2 F2).
admit.
apply nat_trans_id.
- admit.
Admitted.


Definition endo_funs (xs : list (list sort × sort)) (X : functor sortToHSET sortToHSET) :
  functor sortToHSET HSET.
Proof.
set (XS := map (endo_fun X) xs).
(* The output for the empty list *)
set (T := constant_functor sortToHSET HSET emptyHSET).
apply (foldr1 (fun F G => BinProductObject _ (BinProductsSortToHSETToHSET F G)) T XS).
Defined.

(* Definition MSigToFunctor_helper *)
(*   (H : functor sortToHSET sortToHSET → sortToHSET → sort → HSET) : *)
(*  functor [sortToHSET, sortToHSET, has_homsets_sortToHSET] *)
(*          [sortToHSET, sortToHSET, has_homsets_sortToHSET]. *)
(* Proof. *)
(* mkpair. *)
(* + mkpair. *)
(*   - intro X. *)
(*     mkpair. *)
(*     * mkpair. *)
(*     { intro f. *)
(*       apply mk_sortToHSET; intro s. *)
(*       apply (H X f s). *)
(*     } *)
(*       simpl. *)

Arguments pr1 : simpl never.
Arguments pr2 : simpl never.

Definition MSigToFunctor_helper
  (H : sort → functor [sortToHSET,sortToHSET,has_homsets_sortToHSET] [sortToHSET,HSET,has_homsets_HSET]) :
 functor [sortToHSET, sortToHSET, has_homsets_sortToHSET]
         [sortToHSET, sortToHSET, has_homsets_sortToHSET].
Proof.
mkpair.
- mkpair.
  + intro X.
mkpair.
* mkpair.
{ intro f.
  apply mk_sortToHSET; intro s.
  apply (H s X).
  apply f.
}
admit.
*
admit.
+ admit.
- admit.
(* { *)
(*   intros F G α. *)
(* simpl. *)
(* apply nat_trans_id. *)
(* mkpair. *)
(* + *)
(* simpl. *)
(* intro s. *)
(* apply (#(H s X) α). *)
(* + *)
(* now intros s t []. *)
(* } *)
(* * *)
(* split. *)
(* { simpl. *)
(* intros F. *)
(* simpl. *)
(* apply subtypeEquality; [intro x; apply (isaprop_is_nat_trans _ _ has_homsets_HSET)|]. *)
(* simpl. *)

(* apply funextsec; intro t. *)
(* apply (functor_id (H t X)). *)
(* } *)
(* { *)
(* intros F1 F2 F3 αF12 αF23; simpl in *. *)
(* apply subtypeEquality; [intro x; apply (isaprop_is_nat_trans _ _ has_homsets_HSET)|]. *)
(* simpl. *)
(* apply funextsec; intro t. *)
(* apply (functor_comp (H t X)). *)
(* } *)
(* + *)
(* simpl. *)
(* intros F G α. *)
(* mkpair. *)
(* * simpl. *)
(* intros FF. *)
(* mkpair. *)
(* { *)
(* simpl. *)
(* intro s. *)
(* generalize ((α FF)). *)
(* simpl. *)

(* Check (H s). *)

(* admit. *)
(* } *)
(* admit. *)
(* * *)
(* admit. *)
(* - *)
(* admit. *)
Admitted.

Definition MSigToFunctor_helper2
  (H : functor sortToHSET sortToHSET → functor sortToHSET HSET) :
   functor [sortToHSET, sortToHSET, has_homsets_sortToHSET]
           [sortToHSET, HSET, has_homsets_HSET].
Admitted.


Definition MSigToFunctor (M : MSig) :
  functor [sortToHSET,sortToHSET,has_homsets_sortToHSET]
          [sortToHSET,sortToHSET,has_homsets_sortToHSET].
Proof.
apply MSigToFunctor_helper.
intros s.
apply MSigToFunctor_helper2.
intro X.
use (coproduct_of_functors (indices M s)).
+ apply Coproducts_HSET.
  admit.
+ intros y.
  apply (endo_funs (args M s y) X).
Admitted.













End MBindingSig.
