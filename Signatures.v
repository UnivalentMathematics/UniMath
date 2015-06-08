Require Import UniMath.Foundations.Generalities.uu0.
Require Import UniMath.Foundations.hlevel1.hProp.
Require Import UniMath.Foundations.hlevel2.hSet.

Require Import UniMath.RezkCompletion.precategories.
Require Import UniMath.RezkCompletion.functors_transformations.
Require Import SubstSystems.UnicodeNotations.
Require Import UniMath.RezkCompletion.whiskering.
Require Import UniMath.RezkCompletion.Monads.
Require Import UniMath.RezkCompletion.limits.products.
Require Import UniMath.RezkCompletion.limits.coproducts.
Require Import UniMath.RezkCompletion.limits.terminal.
Require Import SubstSystems.Auxiliary.
Require Import SubstSystems.PointedFunctors.
Require Import SubstSystems.ProductPrecategory.
Require Import SubstSystems.HorizontalComposition.
Require Import SubstSystems.PointedFunctorsComposition.
Require Import SubstSystems.FunctorsPointwiseCoproduct.
Require Import SubstSystems.EndofunctorsMonoidal.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Arguments functor_composite {_ _ _} _ _ .
Arguments nat_trans_comp {_ _ _ _ _} _ _ .
Local Notation "G ∙ F" := (functor_composite F G : [ _ , _ , _ ]) (at level 35).
Local Notation "α ∙∙ β" := (hor_comp β α) (at level 20).
Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Local Notation "α 'ø' Z" := (pre_whisker Z α)  (at level 25).
Local Notation "Z ∘ α" := (post_whisker _ _ _ _ α Z) (at level 35).


Section bla.

Variable C : precategory.
Variable hs : has_homsets C.


Section about_signatures.

(** [H] is a rank-2 endofunctor on endofunctors *)
Variable H : functor [C, C, hs] [C, C, hs].

(** The forgetful functor from pointed endofunctors to endofunctors *)
Local Notation "'U'" := (functor_ptd_forget C hs).
(** The precategory of pointed endofunctors on [C] *)
Local Notation "'Ptd'" := (precategory_Ptd C hs).
(** The category of endofunctors on [C] *)
Local Notation "'EndC'":= ([C, C, hs]) .
(** The product of two precategories *)
Local Notation "A 'XX' B" := (product_precategory A B) (at level 2).
(** Pre-whiskering defined as morphism part of the functor given by precomposition 
    with a fixed functor *)
Local Notation "α 'øø' Z" :=  (# (pre_composition_functor_data _ _ _ hs _  Z) α) (at level 25).

(** Objects and morphisms in the product precategory of two precategories *)
Definition prodcatpair (X : functor C C) (Z : Ptd) : ob EndC XX Ptd.
Proof.
  exists X.
  exact Z.
Defined.
Local Notation "A ⊗ B" := (prodcatpair A B) (at level 10).
Definition prodcatmor {X X' : EndC} {Z Z' : Ptd} (α : X ⇒ X') (β : Z ⇒ Z') 
  : X ⊗ Z ⇒ X' ⊗ Z'.
Proof.
  exists α.
  exact β.
Defined.

(** ** Source and target of the natural transformation [θ] *)


(** Source is given by [(X,Z) => H(X)∙U(Z)] *)
Definition θ_source_ob (FX : EndC XX Ptd) : [C, C, hs] := H (pr1 FX) ∙ U (pr2 FX).

Definition θ_source_mor {FX FX' : EndC XX Ptd} (αβ : FX ⇒ FX') 
  : θ_source_ob FX ⇒ θ_source_ob FX' := hor_comp (#U (pr2 αβ)) (#H (pr1 αβ)).


Definition θ_source_functor_data : functor_data (EndC XX Ptd) EndC.
Proof.
  exists θ_source_ob.
  exact (@θ_source_mor).
Defined.

Lemma is_functor_θ_source : is_functor θ_source_functor_data.
Proof.
  split; simpl.
  - intro FX.
    apply nat_trans_eq.
    + apply hs.
    + intro c. simpl.
      rewrite functor_id.
      rewrite id_right.
      set (HH:=functor_id H).
      rewrite HH. apply idpath.
  - intros FX FX' FX'' α β.
    apply nat_trans_eq.
    + apply hs.
    + destruct FX as [F X].
      destruct FX' as [F' X'].
      destruct FX'' as [F'' X''].
      intro c ; simpl in *.
      destruct α as [α a].
      destruct β as [β b]. simpl in *.
      rewrite functor_comp.
      set (HH:=functor_comp H).
      rewrite HH; simpl; clear HH.
      repeat rewrite <- assoc.
      apply maponpaths.
      rewrite <- nat_trans_ax.
      destruct a as [a aax].
      destruct b as [b bax]. simpl in *.
      destruct X as [X eta].
      destruct X' as [X' eta'].
      destruct X'' as [X'' eta'']; simpl in *.
      clear aax eta. clear bax eta'. clear eta''.
      set (HHH:=nat_trans_ax (#H β)).
      rewrite <- functor_comp.
      rewrite assoc.
      rewrite <- functor_comp.
      rewrite HHH.
      apply idpath.
Qed.

Definition θ_source : functor _ _ := tpair _ _ is_functor_θ_source.

(** Target is given by [(X,Z) => H(X∙U(Z))] *)

Definition θ_target_ob (FX : EndC XX Ptd) : EndC := H (pr1 FX ∙ U (pr2 FX)).

Definition θ_target_mor (FX FX' : EndC XX Ptd) (αβ : FX ⇒ FX') 
  : θ_target_ob FX ⇒ θ_target_ob FX'
  := #H (pr1 αβ ∙∙ #U(pr2 αβ)).

Definition θ_target_functor_data : functor_data (EndC XX Ptd) EndC.
Proof.
  exists θ_target_ob.
  exact θ_target_mor.
Defined.


Lemma is_functor_θ_target_functor_data : is_functor θ_target_functor_data.
Proof.
  split; simpl.
  - intro FX; simpl.
    unfold θ_target_mor. 
    set (T:= functor_id_id _ _ H).
    apply T; simpl.
    apply nat_trans_eq.
    + apply hs.
    + intro c; simpl.
      rewrite id_left.
      rewrite functor_id.
      apply idpath.
  - intros FX FX' FX''.
    intros α β.
    unfold θ_target_mor.
    set (T:=functor_comp H _ _ _ (pr1 α ∙∙ # U (pr2 α)) (pr1 β ∙∙ # U (pr2 β))).
    simpl in *.
    match goal with |[ H :  ?f = _ |- _ ] => transitivity f end.
(*    etransitivity. *)
    Focus 2.
      apply T.
    unfold θ_target_mor. simpl.
    apply maponpaths. clear T.
    simpl.
    destruct α as [α a].
    destruct β as [β b]; simpl in *.
    apply nat_trans_eq.
    + apply hs.
    + intro c.
      unfold hor_comp; simpl.
      destruct FX as [F X];
      destruct FX' as [F' X'];
      destruct FX'' as [F'' X'']; simpl in *.
      repeat rewrite <- assoc. apply maponpaths.
      rewrite <- (nat_trans_ax β ((pr1 X') c)).
      rewrite assoc.
      rewrite <- functor_comp.
      rewrite nat_trans_ax.
      apply idpath.
Qed.      

Definition θ_target : functor _ _ := tpair _ _ is_functor_θ_target_functor_data.

(** We assume a suitable (bi)natural transformation [θ] *)
Hypothesis θ : θ_source ⟶ θ_target.

(** [θ] is supposed to satisfy two strength laws *)

Definition θ_Strength1 : UU := ∀ X : EndC,  
  (θ (X ⊗ (id_Ptd C hs))) ;; # H (identity X : functor_composite (functor_identity C) X ⟶ pr1 X) 
          = nat_trans_id _ .

Section Strength_law_1_intensional.

Definition θ_Strength1_int : UU 
  := ∀ X : EndC, 
     θ (X ⊗ (id_Ptd C hs)) ;; # H (λ_functor _ _ ) = λ_functor _ _ .

Lemma θ_Strength1_int_implies_θ_Strength1 : θ_Strength1_int → θ_Strength1.
Proof.
  unfold θ_Strength1_int, θ_Strength1.
  intros T X.
  assert (TX:= T X).
  apply nat_trans_eq; try assumption.
  intro c; simpl.
  assert (T2 := nat_trans_eq_pointwise _ _ _ _ _ _ TX c).
  simpl in *.
  assert (X0 : λ_functor C X = identity (X : EndC)).
  { apply nat_trans_eq; try assumption; intros; apply idpath. }
  rewrite X0 in T2.
  apply T2.
Defined.
  
End Strength_law_1_intensional.

(*
Hypothesis θ_strength1 : θ_Strength1.
*)

Definition θ_Strength2 : UU := ∀ (X : EndC) (Z Z' : Ptd) (Y : EndC)
           (α : functor_compose hs hs (functor_composite (U Z) (U Z')) X ⇒ Y),
    θ (X ⊗ (ptd_composite _ Z Z')) ;; # H α =
    θ (X ⊗ Z') øø (U Z) ;; θ ((functor_compose hs hs (U Z') X) ⊗ Z) ;; 
       # H (α : functor_compose hs hs (U Z) (functor_composite (U Z') X) ⇒ Y).

Section Strength_law_2_intensional.

Definition θ_Strength2_int : UU 
  := ∀ (X : EndC) (Z Z' : Ptd), 
      θ (X ⊗ (ptd_composite _ Z Z'))  ;; #H (α_functor _ (U Z) (U Z') X )  =
      (α_functor _ (U Z) (U Z') (H X) : functor_compose hs hs _ _  ⇒ _ ) ;;  
      θ (X ⊗ Z') øø (U Z) ;; θ ((functor_compose hs hs (U Z') X) ⊗ Z) .

(*

Lemma θ_Strength2_int_implies_θ_Strength2 : θ_Strength2_int → θ_Strength2.
Proof.
  unfold θ_Strength2_int, θ_Strength2.
  intros T X Z Z' Y a.
  assert (TXZZ' := T X Z Z').
  rewrite <- TXZZ'; clear TXZZ'.
  apply nat_trans_eq; try assumption.
  intro c ; simpl.
  rewrite <- assoc.
  apply maponpaths.
    
(*
  match goal with | [ |- ?f ;; ?g = _ ] => 
              pathvia (f ;; (#H (identity _ ) ;; g)) end.
  - rewrite assoc. apply cancel_postcomposition.
    rewrite functor_id.
    apply pathsinv0.
    apply id_right.
  - apply cancel_postcomposition.
    rewrite <- assoc.
    apply maponpaths.
    rewrite <- functor_comp.
    rewrite id_left.
*)    
  assert (X0 : α_functor _ (U Z) (U Z') X = identity (_ : EndC)).
  { apply nat_trans_eq; try assumption; intros; apply idpath. }
  rewrite X0; clear X0.
  apply nat_trans_eq; try assumption.
  intro x; simpl.
  assert (T0 : forall X' c,  pr1 (#H (identity X')) c = identity _ ).
  { intros X' c. rewrite functor_id. apply idpath. }
  
  rewrite <- assoc.
  apply maponpaths.
  admit.
(*  
  assert (T0Xx := T0 (functor_compose hs hs (functor_composite (U Z) (U Z)) X) x).
  admit.
  
  match goal with | [ |- _ = ?f ;; _ ] => set (TTT:= f) end.
  assert (∀ (C : precategory
  
  
  match goal with | [ H : _ = ?x |- ?f ;; ?g = _ ] => 
         pathvia (f ;; x ;; g) end.
  
  
  
  rewrite T0Xx.
  rewrite (T0 _ x).
  
  rewrite <- assoc.
  apply maponpaths.
  apply pathsinv0.
  match goal with |[ |- _ ;; ?f = _ ] => pathvia (identity _ ;; f) end. 
  - apply cancel_postcomposition.
  pathvia (identity _ ;; # H a x).
  - apply cancel_postcomposition.
  eapply pathscomp0.
  
  rewrite (functor_id H).
  
  rewrite assoc.
  apply maponpaths.
  rewrite assoc.
  rewrite assoc.
  assert (TX:= T X).
  apply nat_trans_eq; try assumption.
  intro c; s
*)
Admitted.
*)

End Strength_law_2_intensional.


Hypothesis θ_strength2 : θ_Strength2.


(** Not having a general theory of binatural transformations, we isolate 
    naturality in each component here *)

Lemma θ_nat_1 (X X' : EndC) (α : X ⇒ X') (Z : Ptd) 
  : compose(C:=EndC) (# H α ∙∙ nat_trans_id (pr1 (U Z))) (θ (X' ⊗ Z)) =
        θ (X ⊗ Z);; # H (α ∙∙ nat_trans_id (pr1 (U Z))).
Proof.
  set (t:=nat_trans_ax θ).
  set (t':=t (X ⊗ Z) (X' ⊗ Z)).
  set (t'':= t' (prodcatmor α (identity _ ))).
  simpl in t''.
  exact t''.
Qed.

(* the following makes sense but is wrong
Lemma θ_nat_1' (X X' : EndC) (α : X ⇒ X') (Z : Ptd) 
  : compose(C:=EndC) (# H α øø (U Z)) (θ (X' ⊗ Z)) =
        θ (X ⊗ Z);; # H (α øø (U Z)).
Proof.
  admit.
Qed.
*)

Lemma θ_nat_1_pointwise (X X' : EndC) (α : X ⇒ X') (Z : Ptd) (c : C)
  :  pr1 (# H α) ((pr1 Z) c);; pr1 (θ (X' ⊗ Z)) c =
       pr1 (θ (X ⊗ Z)) c;; pr1 (# H (α ∙∙ nat_trans_id (pr1 Z))) c.
Proof.
  set (t := θ_nat_1 _ _ α Z).
  set (t' := nat_trans_eq_weq _ _ hs _ _ _ _ t c);
  clearbody t';  simpl in t'.
  set (H':= functor_id (H X') (pr1 (pr1 Z) c));
  clearbody H'; simpl in H'.
  match goal with |[H1 : ?f ;; _ ;; ?g = _ , H2 : ?x = _ |- _ ] =>
                        transitivity (f ;; x ;; g) end.
  - repeat rewrite <- assoc. 
    apply maponpaths.
    rewrite H'.
    apply pathsinv0, id_left.
  - apply t'.
Qed.

Lemma θ_nat_2 (X : EndC) (Z Z' : Ptd) (f : Z ⇒ Z')
  : compose (C:=EndC) (identity (H X) ∙∙ pr1 f) (θ (X ⊗ Z')) =
       θ (X ⊗ Z);; # H (identity X ∙∙ pr1 f).
Proof.
  set (t := nat_trans_ax θ).
  set (t' := t (prodcatpair X Z) (prodcatpair X Z') (prodcatmor (identity _ ) f)).
  simpl in t'.
  unfold θ_source_mor in t'.
  unfold θ_target_mor in t'.
  simpl in t'.
  set (T := functor_id H X).
  simpl in *.
  rewrite T in t'. clear T.
  exact t'.
Qed.

Lemma θ_nat_2_pointwise (X : EndC) (Z Z' : Ptd) (f : Z ⇒ Z') (c : C)
  :  # (pr1 (H X)) ((pr1 f) c);; pr1 (θ (X ⊗ Z')) c =
       pr1 (θ (X ⊗ Z)) c;; pr1 (# H (identity X ∙∙ pr1 f)) c .
Proof.
  set (t:=θ_nat_2 X _ _ f).
  set (t':=nat_trans_eq_weq _ _ hs _ _ _ _ t c).
  clearbody t'; clear t.
  simpl in t'.
  rewrite id_left in t'.
  exact t'.
Qed.

End about_signatures.

Section Strength_laws.
(** define strength laws *)

End Strength_laws.

Definition Signature (*C : precategory) (hs : has_homsets C*) : UU 
  := 
  Σ H : functor [C, C, hs] [C, C, hs] , 
     Σ θ : nat_trans (θ_source H) (θ_target H) , θ_Strength1 H θ × θ_Strength2 H θ.

Coercion Signature_Functor (S : Signature) : functor _ _ := pr1 S.

Definition theta (H : Signature) : nat_trans (θ_source H) (θ_target H) := pr1 (pr2 H).

Definition Sig_strength_law1 (H : Signature) : θ_Strength1 _ _ := pr1 (pr2 (pr2 H)).

Definition Sig_strength_law2 (H : Signature) : θ_Strength2 _ _ := pr2 (pr2 (pr2 H)).

End bla.



Arguments theta {_ _} _ .
