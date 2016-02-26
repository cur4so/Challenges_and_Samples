import sys
import pandas as pd
import cPickle as pickle
    
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import TruncatedSVD
from sklearn.svm import LinearSVC
from sklearn import pipeline, grid_search
from sklearn.cross_validation import train_test_split
from sklearn.metrics import make_scorer

from metrics import quadratic_weighted_kappa
    
def main(argv):
    
    if len(argv) < 5:
        sys.exit('please provide\n the path to your data sets;\n train or test or both keyword;\n data file(s) extension (pk or csv);\n \
what column to fit if train mode is set/how to call output if test mode is set;\n \
id column for the final result;\n \
optional:\n \
simple fit or grid search;\n \
save the model created\n')
    
    path=argv[1]
    if not path.endswith('/'):
        path=path+'/'
    train_or_test=argv[2]
    ext=argv[3]
    fit_y=argv[4]
    id='none'
    if len(argv) > 5:
        id=argv[5]
    simple_fit=0
    dump_model=0
    if len(argv) > 6:
        if (argv[6] == 'simple'):
            simple_fit=1
            if (len(argv) > 7 and argv[7] == 'save'):
                dump_model=1
        elif (argv[6] == 'save'):
            dump_model=1
    
    if train_or_test != 'test':
        if ext == 'pk':
            train_features = pd.read_pickle(path + 'train.pk')
        else:
            train_features = pd.read_csv(path + 'train.csv').fillna("")
        if fit_y not in train_features:
            sys.exit(fit_y+' not found in the provided dta set, verify your data and try again')
        y = train_features[fit_y]
        train_features = train_features.drop([fit_y], axis=1)
        if id in train_features:
            train_features = train_features.drop([id], axis=1)

        # -- the model
        svd = TruncatedSVD()
        scl = StandardScaler()
        model = LinearSVC()
        pip = pipeline.Pipeline([('svd', svd),('scl', scl),('svm', model)])

        if simple_fit:
            X_train, X_test, y_train, y_test = train_test_split(train_features, y, test_size=0.1, random_state=0)
    
    
            pip.fit(X_train, y_train)        
            predicted = pip.predict(X_test)
    
            sc = quadratic_weighted_kappa(y_test, predicted)
            print("score: %0.3f" % sc)
            best_model = pip
        else:
        # -- Grid parameter search
            param_grid = {'svd__n_components' : [2,3],'svm__C': [5,10] }
    
            scorer = make_scorer(quadratic_weighted_kappa, greater_is_better = True)
    
            model = grid_search.GridSearchCV(estimator = pip, 
                                             param_grid=param_grid, 
                                             scoring=scorer,
                                             verbose=10, 
                                             n_jobs=-1, 
                                             iid=True, 
                                             refit=True, 
                                             cv=3)
            model.fit(train_features, y)
    
            print("Best score: %0.3f" % model.best_score_)
            print("Best parameters set:")
            best_parameters = model.best_estimator_.get_params()
            for param_name in sorted(param_grid.keys()):
                print("\t%s: %r" % (param_name, best_parameters[param_name]))
    
            best_model = model.best_estimator_
            best_model.fit(train_features,y)
    
        if dump_model:
            with open(path+'model.dmp', 'wb') as f:
                pickle.dump(best_model, f)
            result="model.dmp"
        else:
            result="N/A"
    
    if train_or_test != 'train':
        if ext == 'pk':
            test_features = pd.read_pickle(path + 'test.pk')
        else:
            test_features = pd.read_csv(path + 'test.csv').fillna("")
    
        if train_or_test == 'test':        
            with open(path+'model.dmp', 'rb') as f:
                best_model = pickle.load(f)

        out_id = None
        if id in test_features:
            out_id = test_features[id]
            test_features = test_features.drop([id], axis=1)

        predictions = best_model.predict(test_features)
      
        if out_id is not None:
            result = pd.DataFrame({id : out_id, fit_y : predictions})
        else:
            result = pd.DataFrame({"ID": test_features.index.tolist(), fit_y : predictions})
        result.to_csv(path+"result.csv", index=False)
    
        result="result.csv"
    
    if result == 'N/A':
        return 'none'
    else:
        return path+result
    
if __name__ == "__main__":
    result = main(sys.argv)
    if result != 'none':
        print "the result is in "+result;
