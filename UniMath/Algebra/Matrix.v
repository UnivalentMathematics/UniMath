(** * Matrices

Operations on vectors and matrices.

Author: Langston Barrett (@siddharthist) (March 2018)
*)

Require Import UniMath.Foundations.PartA.
Require Import UniMath.MoreFoundations.PartA.
Require Import UniMath.Combinatorics.FiniteSequences.
Require Import UniMath.Algebra.BinaryOperations.
Require Import UniMath.Algebra.IteratedBinaryOperations.

Require Import UniMath.Algebra.Rigs_and_Rings.

(** ** Contents

 - Vectors
   - Standard conditions on one binary operation
   - Standard conditions on a pair of binary operations
   - Structures
 - Matrices
   - Standard conditions on one binary operation
   - Standard conditions on a pair of binary operations
   - Structures
   - Matrix rig
*)

(** ** Vectors *)

Definition pointwise {X : UU} (n : nat) (op : binop X) : binop (Vector X n) :=
  λ v1 v2 i, op (v1 i) (v2 i).

(** *** Standard conditions on one binary operation *)

(** Most features of binary operations (associativity, unity, etc) carry over to
    pointwise operations. *)
Section OneOp.
  Context {X : UU} {n : nat} {op : binop X}.

  Definition pointwise_assoc (assocax : isassoc op) : isassoc (pointwise n op).
  Proof.
    intros ? ? ?; apply funextfun; intro; apply assocax.
  Defined.

  Definition pointwise_lunit (lun : X) (lunax : islunit op lun) :
    islunit (pointwise n op) (const_vec lun).
  Proof.
    intros ?; apply funextfun; intro; apply lunax.
  Defined.

  Definition pointwise_runit (run : X) (runax : isrunit op run) :
    isrunit (pointwise n op) (const_vec run).
  Proof.
    intros ?; apply funextfun; intro; apply runax.
  Defined.

  Definition pointwise_unit (un : X) (unax : isunit op un) :
    isunit (pointwise n op) (const_vec un).
  Proof.
    use isunitpair.
    - apply pointwise_lunit; exact (pr1 unax).
    - apply pointwise_runit; exact (pr2 unax).
  Defined.

  Definition pointwise_comm (commax : iscomm op) : iscomm (pointwise n op).
  Proof.
    intros ? ?; apply funextfun; intro; apply commax.
  Defined.

  Definition pointwise_monoidop (monoidax : ismonoidop op) :
    ismonoidop (pointwise n op).
  Proof.
    use mk_ismonoidop.
    - apply pointwise_assoc, assocax_is; assumption.
    - use isunitalpair.
      + apply (const_vec (unel_is monoidax)).
      + apply pointwise_unit, unax_is.
  Defined.

  Definition pointwise_abmonoidop (abmonoidax : isabmonoidop op) :
    isabmonoidop (pointwise n op).
  Proof.
    use mk_isabmonoidop.
    - apply pointwise_monoidop; exact (pr1isabmonoidop _ _ abmonoidax).
    - apply pointwise_comm; exact (pr2 abmonoidax).
  Defined.

End OneOp.

(** *** Standard conditions on a pair of binary operations *)

Section TwoOps.
  Context {X : UU} {n : nat} {op : binop X} {op' : binop X}.

  Definition pointwise_ldistr (isldistrax : isldistr op op') :
    isldistr (pointwise n op) (pointwise n op').
  Proof.
    intros ? ? ?; apply funextfun; intro; apply isldistrax.
  Defined.

  Definition pointwise_rdistr (isrdistrax : isrdistr op op') :
    isrdistr (pointwise n op) (pointwise n op').
  Proof.
    intros ? ? ?; apply funextfun; intro; apply isrdistrax.
  Defined.

  Definition pointwise_distr (isdistrax : isdistr op op') :
    isdistr (pointwise n op) (pointwise n op').
  Proof.
    use dirprodpair.
    - apply pointwise_ldistr; apply (dirprod_pr1 isdistrax).
    - apply pointwise_rdistr; apply (dirprod_pr2 isdistrax).
  Defined.

  Definition pointwise_isrigops (isrigopsax : isrigops op op') :
    isrigops (pointwise n op) (pointwise n op').
  Proof.
    use mk_isrigops.
    - apply pointwise_abmonoidop, (rigop1axs_is isrigopsax).
    - apply pointwise_monoidop, (rigop2axs_is isrigopsax).
    - intro; apply funextfun; intro;
        apply (dirprod_pr1 (pr2 (dirprod_pr1 isrigopsax))).
    - intro; apply funextfun; intro;
        apply (dirprod_pr2 (pr2 (dirprod_pr1 isrigopsax))).
    - apply pointwise_distr, rigdistraxs_is; assumption.
  Defined.

End TwoOps.

(** *** Structures *)

Section Structures.

  Definition pointwise_hSet (X : hSet) (n : nat) : hSet.
  Proof.
    use hSetpair.
    - exact (Vector X n).
    - change isaset with (isofhlevel 2).
      apply vector_hlevel, setproperty.
  Defined.

  Definition pointwise_setwithbinop (X : setwithbinop) (n : nat) : setwithbinop.
  Proof.
    use setwithbinoppair.
    - apply pointwise_hSet; [exact X|assumption].
    - exact (pointwise n op).
  Defined.

  Definition pointwise_setwith2binop (X : setwith2binop) (n : nat) : setwith2binop.
  Proof.
    use setwith2binoppair.
    - apply pointwise_hSet; [exact X|assumption].
    - split.
      + exact (pointwise n op1).
      + exact (pointwise n op2).
  Defined.

  Definition pointwise_monoid (X : monoid) (n : nat) : monoid.
  Proof.
    use monoidpair.
    - apply pointwise_setwithbinop; [exact X|assumption].
    - apply pointwise_monoidop; exact (pr2 X).
  Defined.

  Definition pointwise_abmonoid (X : abmonoid) (n : nat) : abmonoid.
  Proof.
    use abmonoidpair.
    - apply pointwise_setwithbinop; [exact X|assumption].
    - apply pointwise_abmonoidop; exact (pr2 X).
  Defined.

  Definition pointwise_rig (X : rig) (n : nat) : rig.
  Proof.
    use rigpair.
    - apply pointwise_setwith2binop; [exact X|assumption].
    - apply pointwise_isrigops; exact (pr2 X).
  Defined.

End Structures.

(** ** Matrices *)

Definition entrywise {X : UU} (n m : nat) (op : binop X) : binop (Matrix X n m) :=
  λ mat1 mat2 i, pointwise _ op (mat1 i) (mat2 i).

(** *** Standard conditions on one binary operation *)

Section OneOpMat.
  Context {X : UU} {n m : nat} {op : binop X}.

  Definition entrywise_assoc (assocax : isassoc op) : isassoc (entrywise n m op).
  Proof.
    intros ? ? ?; apply funextfun; intro; apply pointwise_assoc, assocax.
  Defined.

  Definition entrywise_lunit (lun : X) (lunax : islunit op lun) :
    islunit (entrywise n m op) (const_matrix lun).
  Proof.
    intros ?; apply funextfun; intro; apply pointwise_lunit, lunax.
  Defined.

  Definition entrywise_runit (run : X) (runax : isrunit op run) :
    isrunit (entrywise n m op) (const_matrix run).
  Proof.
    intros ?; apply funextfun; intro; apply pointwise_runit, runax.
  Defined.

  Definition entrywise_unit (un : X) (unax : isunit op un) :
    isunit (entrywise n m op) (const_matrix un).
  Proof.
    use isunitpair.
    - apply entrywise_lunit; exact (pr1 unax).
    - apply entrywise_runit; exact (pr2 unax).
  Defined.

  Definition entrywise_comm (commax : iscomm op) : iscomm (entrywise n m op).
  Proof.
    intros ? ?; apply funextfun; intro; apply pointwise_comm, commax.
  Defined.

  Definition entrywise_monoidop (monoidax : ismonoidop op) :
    ismonoidop (entrywise n m op).
  Proof.
    use mk_ismonoidop.
    - apply entrywise_assoc, assocax_is; assumption.
    - use isunitalpair.
      + apply (const_matrix (unel_is monoidax)).
      + apply entrywise_unit, unax_is.
  Defined.

  Definition entrywise_abmonoidop (abmonoidax : isabmonoidop op) :
    isabmonoidop (entrywise n m op).
  Proof.
    use mk_isabmonoidop.
    - apply entrywise_monoidop; exact (pr1isabmonoidop _ _ abmonoidax).
    - apply entrywise_comm; exact (pr2 abmonoidax).
  Defined.

End OneOpMat.

(** *** Standard conditions on a pair of binary operations *)

Section TwoOpsMat.
  Context {X : UU} {n m : nat} {op : binop X} {op' : binop X}.

  Definition entrywise_ldistr (isldistrax : isldistr op op') :
    isldistr (entrywise n m op) (entrywise n m op').
  Proof.
    intros ? ? ?; apply funextfun; intro; apply pointwise_ldistr, isldistrax.
  Defined.

  Definition entrywise_rdistr (isrdistrax : isrdistr op op') :
    isrdistr (entrywise n m op) (entrywise n m op').
  Proof.
    intros ? ? ?; apply funextfun; intro; apply pointwise_rdistr, isrdistrax.
  Defined.

  Definition entrywise_distr (isdistrax : isdistr op op') :
    isdistr (entrywise n m op) (entrywise n m op').
  Proof.
    use dirprodpair.
    - apply entrywise_ldistr; apply (dirprod_pr1 isdistrax).
    - apply entrywise_rdistr; apply (dirprod_pr2 isdistrax).
  Defined.

  Definition entrywise_isrigops (isrigopsax : isrigops op op') :
    isrigops (entrywise n m op) (entrywise n m op').
  Proof.
    use mk_isrigops.
    - apply entrywise_abmonoidop, (rigop1axs_is isrigopsax).
    - apply entrywise_monoidop, (rigop2axs_is isrigopsax).
    - do 2 (intro; apply funextfun); intro;
        apply (dirprod_pr1 (pr2 (dirprod_pr1 isrigopsax))).
    - do 2 (intro; apply funextfun); intro;
        apply (dirprod_pr2 (pr2 (dirprod_pr1 isrigopsax))).
    - apply entrywise_distr, rigdistraxs_is; assumption.
  Defined.

End TwoOpsMat.

(** *** Structures *)

(** *** Matrix rig *)

Section MatrixMult.

  Context {R : rig}.

  (** Summation and pointwise multiplication *)
  Local Notation Σ := (iterop_fun rigunel1 op1).
  Local Notation "R1 ^ R2" := ((pointwise _ op2) R1 R2).

  (** If A is m × n (so B is n × p),
      <<
        AB(i, j) = A(i, 1) * B(1, j) + A(i, 2) * B(2, j) + ⋯ + A(i, n) * B(n, j)
      >>
      The order of the arguments allows currying the first matrix.
  *)
  Definition matrix_mult {m n : nat} (mat1 : Matrix R m n)
                         {p : nat} (mat2 : Matrix R n p) : (Matrix R m p) :=
    λ i j, Σ ((row mat1 i) ^ (col mat2 j)).

  Local Notation "A ** B" := (matrix_mult A B) (at level 80).

  Lemma identity_matrix {n : nat} : (Matrix R n n).
  Proof.
    intros i j.
    induction (stn_eq_or_neq i j).
    - exact (rigunel2). (* The multiplicative identity *)
    - exact (rigunel1). (* The additive identity *)
  Defined.

  (*
  Lemma matrix_mult_assoc {m n : nat} (mat1 : Matrix R m n)
                          {p : nat} (mat2 : Matrix R n p)
                          {q : nat} (mat3 : Matrix R p q) :
    ((mat1 ** mat2) ** mat3) = (mat1 ** (mat2 ** mat3)).
  *)
End MatrixMult.