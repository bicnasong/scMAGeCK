\name{scmageck_eff_estimate}
\alias{scmageck_eff_estimate}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Detect heterogenous perturbation responses from Perturb-seq like data
}
\description{
echo "This function uses constrained linear least squares to identify heterogenous perturbation effects from single-cell CRISPR screens (e.g., Perturb-seq, CROP-seq)."
}
\usage{
scmageck_eff_estimate(
  rds_object, 
  bc_frame, 
  perturb_gene, 
  non_target_ctrl, 
  perturb_target_gene = NULL, 
  scale_factor = 3, 
  target_gene_min = 200, 
  target_gene_max = 500,
  assay_for_cor = 'MAGIC_RNA', 
  subset_rds = TRUE, 
  scale_score = TRUE,
  perturb_gene_exp_id_list = NULL,
  lambda = 0,
  background_correction=FALSE
)
 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{rds_object}{
  A Seurat object or local RDS file path that contains the scRNA-seq dataset; 
  or a path to RDS file.
  Note that the dataset has to be normalized and scaled. 
  }
  \item{bc_frame}{
  A txt file to include cell identity information, generated from the cell 
  identity collection step; or a corresponding data.frame.
  }
  \item{perturb_gene}{
  The list of perturbed genes. By default, all genes in the table are 
  subject to regression. 
  }
  \item{non_target_control}{
  The list of genes (separated by ",") served as negative controls.
  }
  \item{perturb_target_gene}{
  The list of target genes for modeling. 
  If null, will automatic search and identify the target genes.
  }
  \item{scale_factor}{
  The upper bound of the constraints. Must be a positive value.
  Default 3. Assign a higher value for a more continuous distribution
  of the signa scores.
  }
  \item{target_gene_min}{
  The minimum number of genes selected for target genes. 
  }
  \item{target_gene_max}{
  The maximum number of genes selected for target genes. 
  }
  \item{assay_for_cor}{
  The assays used for estimating correlation. 
  Default: MAGIC_RNA, which is generated by MAGIC.
  }
  \item{subset_rds}{
  Whether to return an R object that only contains cells that express guides 
  targeting perturbed genes (or negative control genes).
  Default: TRUE
  }
  \item{scale_score}{
  Whether to scale the scores for each gene to 1.
  Default: TRUE
  }
  \item{perturb_gene_exp_id_list}{
  If the perturbed_gene id is different from expression feature id, 
  use this parameter to provide the corresponding expression features. 
  Must be the same length as perturb_gene.
  Default: NULL
  }
  \item{lambda}{
  Sparse penalty (similar with the lambda value in LASSO reguession). Must be non-negative. 
  Default: 0
  }
  \item{background_correction}{
  Whether to extract background gene expression, which is estimated from negative control cells. 
  Turn this option on will reduce false positives in datasets containing multiple cell types, where gene expressions may be largely different from different cell types.
  Default: False
  }

}
\value{
Returns a list of several items:
  eff_matrix: the sigma score matrix containing the scores of each cells for each perturbed gene
  rds:   the R object if subset_rds is set as TRUE
  optimization_matrix: the matrix used for actually performing the constrained optimizaiton
  target_gene_search_result: the results of target gene search for each perturbed gene
}
\examples{

    library(Seurat)
    # set the BARCODE and RDS file path 
    BARCODE = system.file("extdata","barcode_rec.txt",package = "scMAGeCK")
    bc_frame=read.table(BARCODE,header = T,as.is = T)
    
    # needs clean later, but cell identity will need to be fixed
    bc_frame$cell=sub('-1','',bc_frame$cell)
    
    
    ## RDS can be a Seurat object or local RDS file path that contains the scRNA-seq dataset
    RDS = system.file("extdata","singles_dox_mki67_v3.RDS",package = "scMAGeCK")
    rds_object=readRDS(RDS)
    
    # Run scmageck_eff_estimate function
    # By default, the result will be saved to the current working directory. 
    rds_object<-assign_cell_identity(bc_frame,rds_object)
    
    eff_object <- scmageck_eff_estimate(rds_object, bc_frame, perturb_gene='TP53', 
                                        non_target_ctrl = 'NonTargetingControlGuideForHuman',assay_for_cor='RNA')
    
    eff_estimat=eff_object$eff_matrix
    rds_subset=eff_object$rds
    
    # TP53 scores clearly show the pattern of clustering
    FeaturePlot(rds_subset,features='TP53_eff',reduction = 'tsne')
    
    # whereas TP53 gene expression did not have this pattern
    FeaturePlot(rds_subset,features='TP53',reduction = 'tsne')



}
