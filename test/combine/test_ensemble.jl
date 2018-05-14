module TestEnsembleMethods

include(joinpath("..", "fixture_learners.jl"))
using .FixtureLearners
nfcp = NumericFeatureClassification()

using FactCheck

importall Combine.Transformers.EnsembleMethods
import Combine.Transformers.DecisionTreeWrapper: fit!, transform!
import Combine.Transformers.DecisionTreeWrapper: PrunedTree
import Combine.Transformers.DecisionTreeWrapper: RandomForest
import Combine.Transformers.DecisionTreeWrapper: DecisionStumpAdaboost

facts("Ensemble learners") do
  context("VoteEnsemble predicts according to majority") do
    always_a_options = Dict( :label => "a" )
    always_b_options = Dict( :label => "b" ) 
    learner = VoteEnsemble(Dict(
      :learners => [
        AlwaysSameLabelLearner(always_a_options),
        AlwaysSameLabelLearner(always_a_options),
        AlwaysSameLabelLearner(always_b_options)
      ]
     ))
    fit!(learner, nfcp.train_instances, nfcp.train_labels)
    predictions = transform!(learner, nfcp.test_instances)
    expected_predictions = fill("a", size(nfcp.test_instances, 1))

    @fact predictions --> expected_predictions
  end

#  context("StackEnsemble predicts with combined learners") do
#    # Fix random seed, due to stochasticity in stacker.
#    srand(2)
#
#    always_a_options = Dict( :label => "a" )
#    learner = StackEnsemble(Dict(
#      :learners => [
#        AlwaysSameLabelLearner(always_a_options),
#        AlwaysSameLabelLearner(always_a_options),
#        PerfectScoreLearner()
#      ],
#      :keep_original_features => true
#     ))
#    fit!(learner, nfcp.train_instances, nfcp.train_labels)
#    predictions = transform!(learner, nfcp.test_instances)
#    unexpected_predictions = fill("a", size(nfcp.test_instances, 1))
#
#    @fact predictions --> not(unexpected_predictions)
#  end

#  context("BestLearner picks the best learner") do
#    always_a_options = Dict( :label => "a" )
#    always_b_options = Dict( :label => "b" )
#    learner = BestLearner(Dict(
#      :learners => [
#        AlwaysSameLabelLearner(always_a_options),
#        PerfectScoreLearner(),
#        AlwaysSameLabelLearner(always_b_options)
#      ]
#     ))
#    fit!(learner, nfcp.train_instances, nfcp.train_labels)
#
#    @fact learner.model[:best_learner_index] --> 2
#  end

#  context("BestLearner conducts grid search") do
#    learner = BestLearner(Dict(
#      :learners => [PrunedTree(), DecisionStumpAdaboost(), RandomForest()],
#      :learner_options_grid => [
#       Dict( 
#          :impl_options => Dict(
#            :purity_threshold => [0.5, 1.0]
#           ) 
#         ),
#        Dict(),
#        Dict( 
#          :impl_options => Dict(
#            :num_trees => [5, 10, 20], 
#            :partial_sampling => [0.5, 0.7]
#           )
#         ) 
#      ]
#     ))
#    fit!(learner, nfcp.train_instances, nfcp.train_labels)
#
#    @fact length(learner.model[:learners]) --> 8
#  end
end

end # module
